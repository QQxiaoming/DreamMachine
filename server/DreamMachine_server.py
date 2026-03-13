#!/usr/bin/env python3
import argparse
import base64
import importlib
import importlib.util
import io
import json
import os
import socket
import struct
import sys
import traceback

import numpy as np
import torch
from PIL import Image, ImageOps, ImageSequence

folder_paths = None
nodes = None
node_helpers = None
comfy = None


def _resolve_comfy_root():
    # 支持脚本在 ComfyUI 根目录或其上一级目录执行
    script_dir = os.path.dirname(os.path.abspath(__file__))
    env_root = os.environ.get("COMFYUI_ROOT")

    candidates = []
    if env_root:
        candidates.append(env_root)
    candidates.extend(
        [
            os.path.join(script_dir, "ComfyUI"),
            script_dir,
            os.path.join(os.getcwd(), "ComfyUI"),
            os.getcwd(),
        ]
    )

    for path in candidates:
        root = os.path.abspath(path)
        if (
            os.path.isfile(os.path.join(root, "folder_paths.py"))
            and os.path.isdir(os.path.join(root, "comfy"))
        ):
            return root

    raise ModuleNotFoundError(
        "Cannot locate ComfyUI root. Set COMFYUI_ROOT or run from ComfyUI/(parent)."
    )


COMFY_ROOT = None


def _get_comfy_root():
    global COMFY_ROOT
    if COMFY_ROOT is None:
        COMFY_ROOT = _resolve_comfy_root()
    return COMFY_ROOT


def _prepare_import_path():
    # 确保当前仓库根目录优先于系统路径，避免导入到同名第三方模块
    comfy_root = _get_comfy_root()
    if comfy_root in sys.path:
        sys.path.remove(comfy_root)
    sys.path.insert(0, comfy_root)


def _bootstrap_comfy_imports():
    global folder_paths, nodes, node_helpers, comfy
    if getattr(_bootstrap_comfy_imports, "_ran", False):
        return

    _prepare_import_path()
    folder_paths = importlib.import_module("folder_paths")
    nodes = importlib.import_module("nodes")
    node_helpers = importlib.import_module("node_helpers")
    comfy = importlib.import_module("comfy")
    importlib.import_module("comfy.sd")
    importlib.import_module("comfy.model_management")

    _bootstrap_comfy_imports._ran = True


def _fix_shadowed_utils_module():
    # 若已加载的是单文件 utils.py（非包），先移除，后续强制加载本地 utils 包
    loaded_utils = sys.modules.get("utils")
    if loaded_utils is not None and not hasattr(loaded_utils, "__path__"):
        del sys.modules["utils"]


def _force_load_local_utils_package():
    comfy_root = _get_comfy_root()
    utils_init = os.path.join(comfy_root, "utils", "__init__.py")
    if not os.path.exists(utils_init):
        raise ModuleNotFoundError(f"Local utils package not found: {utils_init}")

    spec = importlib.util.spec_from_file_location(
        "utils",
        utils_init,
        submodule_search_locations=[os.path.join(comfy_root, "utils")],
    )
    if spec is None or spec.loader is None:
        raise ModuleNotFoundError("Failed to build module spec for local utils package")

    module = importlib.util.module_from_spec(spec)
    sys.modules["utils"] = module
    spec.loader.exec_module(module)


def _prime_local_utils_package():
    # 预热本地 utils 包，并提前导入 install_util，保证后续依赖可用
    _fix_shadowed_utils_module()
    _force_load_local_utils_package()
    importlib.import_module("utils.install_util")


def ensure_extra_nodes_loaded():
    """Load comfy_extras once for built-in extra nodes."""
    if getattr(ensure_extra_nodes_loaded, "_ran", False):
        return
    _bootstrap_comfy_imports()
    _prepare_import_path()
    _prime_local_utils_package()
    # Load built-in extras (needed for TextEncodeQwenImageEditPlus)
    import asyncio

    asyncio.run(nodes.init_extra_nodes(init_custom_nodes=False, init_api_nodes=False))
    ensure_extra_nodes_loaded._ran = True


def load_image(image_bytes):
    img = node_helpers.pillow(Image.open, io.BytesIO(image_bytes))

    output_images = []
    output_masks = []
    w, h = None, None

    excluded_formats = ["MPO"]

    for i in ImageSequence.Iterator(img):
        i = node_helpers.pillow(ImageOps.exif_transpose, i)

        if i.mode == "I":
            i = i.point(lambda p: p * (1 / 255))
        image = i.convert("RGB")

        if len(output_images) == 0:
            w = image.size[0]
            h = image.size[1]

        if image.size[0] != w or image.size[1] != h:
            # 多帧图像中尺寸不一致的帧直接跳过，保持 batch 可拼接
            continue

        image = np.array(image).astype(np.float32) / 255.0
        image = torch.from_numpy(image)[None,]
        if "A" in i.getbands():
            # ComfyUI 掩码约定：1 表示需要保留，故对 alpha 做反相
            mask = np.array(i.getchannel("A")).astype(np.float32) / 255.0
            mask = 1.0 - torch.from_numpy(mask)
        elif i.mode == "P" and "transparency" in i.info:
            mask = np.array(i.convert("RGBA").getchannel("A")).astype(np.float32) / 255.0
            mask = 1.0 - torch.from_numpy(mask)
        else:
            mask = torch.zeros((64, 64), dtype=torch.float32, device="cpu")
        output_images.append(image)
        output_masks.append(mask.unsqueeze(0))

    if not output_images:
        raise ValueError("No valid frame found in input image bytes")

    if len(output_images) > 1 and img.format not in excluded_formats:
        output_image = torch.cat(output_images, dim=0)
        output_mask = torch.cat(output_masks, dim=0)
    else:
        output_image = output_images[0]
        output_mask = output_masks[0]

    return output_image, output_mask, w, h


def encode_image(imagedata, image_format="PNG"):
    # 仅编码最后一张（当前脚本 batch_size=1，保持原行为不改）
    img = None
    for _, image in enumerate(imagedata):
        i = 255.0 * image.cpu().numpy()
        img = Image.fromarray(np.clip(i, 0, 255).astype(np.uint8))
    if img is None:
        raise ValueError("No decoded image data to encode")

    with io.BytesIO() as out:
        img.save(out, format=image_format)
        return out.getvalue()


def _extract_input_images_b64(req):
    input_images_b64 = req.get("input_images_b64")
    if input_images_b64 is None:
        # 兼容旧协议：单图字段
        legacy_image_b64 = req.get("input_image_b64")
        if legacy_image_b64:
            input_images_b64 = [legacy_image_b64]
        else:
            input_images_b64 = []

    if len(input_images_b64) > 4:
        raise ValueError("input_images_b64 supports up to 4 images")

    return input_images_b64


def _normalize_output_format(req):
    output_format = str(req.get("output_format", "PNG")).upper()
    if output_format not in {"PNG", "JPEG", "JPG", "WEBP"}:
        raise ValueError(f"Unsupported output_format: {output_format}")
    if output_format == "JPG":
        output_format = "JPEG"
    return output_format


def _get_first_image_size(image_b64):
    image_bytes = base64.b64decode(image_b64)
    with Image.open(io.BytesIO(image_bytes)) as image:
        return image.width, image.height


def _build_mock_image_bytes(width, height, seed, image_format):
    # 生成一张可重复的伪彩色渐变图，便于客户端验证收包与解码链路
    x = np.linspace(0, 255, num=width, dtype=np.uint8)
    y = np.linspace(0, 255, num=height, dtype=np.uint8)
    xx, yy = np.meshgrid(x, y)

    xx16 = xx.astype(np.uint16)
    yy16 = yy.astype(np.uint16)
    r = (xx16 + (seed & 0xFF)) % 256
    g = (yy16 + ((seed >> 8) & 0xFF)) % 256
    b = ((xx16 // 2) + (yy16 // 2) + ((seed >> 16) & 0xFF)) % 256
    mock_rgb = np.stack([r, g, b], axis=-1).astype(np.uint8)

    with io.BytesIO() as out:
        Image.fromarray(mock_rgb, mode="RGB").save(out, format=image_format)
        return out.getvalue()


def _force_cpu_mode():
    # 强制切到 CPU 并清空已加载模型缓存，避免显存路径残留
    from comfy.cli_args import args as comfy_args

    comfy_args.cpu = True
    comfy.model_management.cpu_state = comfy.model_management.CPUState.CPU
    comfy.model_management.unload_all_models()
    comfy.model_management.soft_empty_cache(force=True)


def _run_once(model_params, pos_image, neg_image, pos_prompt, neg_prompt, target_width, target_height):
    latent_cls = nodes.NODE_CLASS_MAPPINGS["EmptyLatentImage"]
    latent = getattr(latent_cls(), latent_cls.FUNCTION)(
        width=target_width, height=target_height, batch_size=1
    )[0]

    te_cls = nodes.NODE_CLASS_MAPPINGS["TextEncodeQwenImageEditPlus"]
    te_fn = getattr(te_cls(), te_cls.FUNCTION)
    # 正向条件带参考图与目标 latent，负向条件保持空提示
    pos = te_fn(
        clip=model_params["clip"],
        vae=model_params["vae"],
        image1=pos_image[0],
        image2=pos_image[1],
        image3=pos_image[2],
        image4=pos_image[3],
        target_latent=latent,
        prompt=pos_prompt,
    )[0]
    neg = te_fn(
        clip=model_params["clip"],
        vae=model_params["vae"],
        image1=neg_image[0],
        image2=neg_image[1],
        image3=neg_image[2],
        image4=neg_image[3],
        prompt=neg_prompt,
    )[0]

    ks_cls = nodes.NODE_CLASS_MAPPINGS["KSampler"]
    sampled = getattr(ks_cls(), ks_cls.FUNCTION)(
        model=model_params["model"],
        positive=pos,
        negative=neg,
        latent_image=latent,
        seed=model_params["seed"],
        steps=model_params["steps"],
        cfg=model_params["cfg"],
        sampler_name=model_params["sampler_name"],
        scheduler=model_params["scheduler"],
        denoise=model_params["denoise"],
    )[0]

    decode_cls = nodes.NODE_CLASS_MAPPINGS["VAEDecode"]
    return getattr(decode_cls(), decode_cls.FUNCTION)(samples=sampled, vae=model_params["vae"])[0]


def _recv_exact(conn, n):
    buf = bytearray()
    while len(buf) < n:
        chunk = conn.recv(n - len(buf))
        if not chunk:
            raise ConnectionError("Connection closed while receiving data")
        buf.extend(chunk)
    return bytes(buf)


def recv_packet(conn):
    header = _recv_exact(conn, 4)
    body_len = struct.unpack("!I", header)[0]
    body = _recv_exact(conn, body_len)
    return json.loads(body.decode("utf-8"))


def send_packet(conn, payload):
    body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
    header = struct.pack("!I", len(body))
    conn.sendall(header + body)


class DreamMachineService:
    def __init__(self, ckpt_path, cpu_mode=False, fake_mode=False):
        self._ckpt_path = ckpt_path
        self._fake_mode = bool(fake_mode)
        self._model = None
        self._clip = None
        self._vae = None

        if self._fake_mode:
            print("[DreamMachineServer] fake mode enabled: skip model loading and real inference")
            return

        _bootstrap_comfy_imports()
        ensure_extra_nodes_loaded()

        if cpu_mode:
            _force_cpu_mode()

        self._load_checkpoint(ckpt_path)

    def _load_checkpoint(self, ckpt_path):
        out = comfy.sd.load_checkpoint_guess_config(
            ckpt_path,
            output_vae=True,
            output_clip=True,
            embedding_directory=folder_paths.get_folder_paths("embeddings"),
        )
        self._model, self._clip, self._vae = out[:3]
        self._ckpt_path = ckpt_path

    def _infer_fake(self, req):
        input_images_b64 = _extract_input_images_b64(req)
        output_format = _normalize_output_format(req)
        seed = int(req.get("seed", int.from_bytes(os.urandom(4), "big")))

        target_width = req.get("target_width")
        target_height = req.get("target_height")
        width = int(target_width) if target_width is not None else None
        height = int(target_height) if target_height is not None else None

        if input_images_b64 and (width is None or width <= 0 or height is None or height <= 0):
            image_width, image_height = _get_first_image_size(input_images_b64[0])
            if width is None or width <= 0:
                width = image_width
            if height is None or height <= 0:
                height = image_height

        if width is None or width <= 0:
            width = 512
        if height is None or height <= 0:
            height = 512

        output_image_bytes = _build_mock_image_bytes(width, height, seed, output_format)
        output_image_b64 = base64.b64encode(output_image_bytes).decode("ascii")
        
        import time
        time.sleep(10)
        
        return {
            "ok": True,
            "output_image_b64": output_image_b64,
            "output_format": output_format,
            "seed": seed,
            "width": width,
            "height": height,
            "ckpt_path": self._ckpt_path,
            "fake_mode": True,
        }

    def infer(self, req):
        if self._fake_mode:
            return self._infer_fake(req)

        input_images_b64 = _extract_input_images_b64(req)

        prompt = req["prompt"]
        neg_prompt = req.get("neg_prompt", "")
        output_format = _normalize_output_format(req)

        input_images = []
        for image_b64 in input_images_b64:
            image_bytes = base64.b64decode(image_b64)
            image, _, w, h = load_image(image_bytes)
            input_images.append((image, w, h))

        if input_images:
            # 第 1 张作为主图，并用其尺寸作为目标生成尺寸
            main_image, width, height = input_images[0]
            target_width = req.get("target_width")
            target_height = req.get("target_height")
            if target_width is not None:
                target_width = int(target_width)
                if target_width > 0:
                    width = target_width
            if target_height is not None:
                target_height = int(target_height)
                if target_height > 0:
                    height = target_height
        else:
            target_width = req.get("target_width")
            target_height = req.get("target_height")
            if target_width is None or target_height is None:
                raise ValueError(
                    "When no input image is provided, target_width and target_height are required"
                )
            width = int(target_width)
            height = int(target_height)
            if width <= 0 or height <= 0:
                raise ValueError("target_width and target_height must be positive integers")
            main_image = None

        model_params = {
            "model": self._model,
            "clip": self._clip,
            "vae": self._vae,
            "seed": int(req.get("seed", int.from_bytes(os.urandom(4), "big"))),
            "steps": int(req.get("steps", 4)),
            "cfg": float(req.get("cfg", 1.0)),
            "sampler_name": req.get("sampler_name", "sa_solver"),
            "scheduler": req.get("scheduler", "beta"),
            "denoise": float(req.get("denoise", 1.0)),
        }

        pos_image = [main_image, None, None, None]
        for i in range(1, min(4, len(input_images))):
            pos_image[i] = input_images[i][0]
        neg_image = [None, None, None, None]

        decoded = _run_once(
            model_params=model_params,
            pos_image=pos_image,
            neg_image=neg_image,
            pos_prompt=prompt,
            neg_prompt=neg_prompt,
            target_width=width,
            target_height=height,
        )
        output_image_bytes = encode_image(decoded, image_format=output_format)
        output_image_b64 = base64.b64encode(output_image_bytes).decode("ascii")

        return {
            "ok": True,
            "output_image_b64": output_image_b64,
            "output_format": output_format,
            "seed": model_params["seed"],
            "width": width,
            "height": height,
            "ckpt_path": self._ckpt_path,
            "fake_mode": False,
        }


def serve_forever(host, port, service):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server:
        server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        server.bind((host, port))
        server.listen(1)
        print(f"[DreamMachineServer] listening on {host}:{port}")

        while True:
            conn, addr = server.accept()
            print(f"[DreamMachineServer] client connected: {addr}")
            with conn:
                try:
                    req = recv_packet(conn)
                    resp = service.infer(req)
                except Exception as e:
                    resp = {
                        "ok": False,
                        "error": str(e),
                        "traceback": traceback.format_exc(),
                    }
                send_packet(conn, resp)
            print(f"[DreamMachineServer] client disconnected: {addr}")


def parse_args():
    p = argparse.ArgumentParser(description="DreamMachine TCP inference server")
    p.add_argument("--host", default="127.0.0.1")
    p.add_argument("--port", type=int, default=17890)
    p.add_argument(
        "--ckpt_path",
        default="/Volumes/Work/ComfyUI/models/checkpoints/Qwen-Rapid-AIO-NSFW-v19.safetensors",
        #default="D:\\ComfyUI_Mie_V6.01\\ComfyUI\\models\\checkpoints\\QWEN\\Qwen-Rapid-AIO-NSFW-v19.safetensors",
    )
    p.add_argument("--cpu_mode", action="store_true", help="Force CPU mode")
    p.add_argument(
        "--fake_mode",
        action="store_true",
        help="Skip model loading/inference and return a synthetic image for client tests",
    )
    return p.parse_args()


def main():
    args = parse_args()
    service = DreamMachineService(
        ckpt_path=args.ckpt_path,
        cpu_mode=args.cpu_mode,
        fake_mode=args.fake_mode,
    )
    serve_forever(args.host, args.port, service)


if __name__ == "__main__":
    torch.set_grad_enabled(False)
    with torch.inference_mode():
        main()
