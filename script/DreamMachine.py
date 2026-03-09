#!/usr/bin/env python3
import argparse
import base64
import json
import os
import socket
import struct


def send_packet(conn, payload):
    body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
    header = struct.pack("!I", len(body))
    conn.sendall(header + body)


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


def parse_args():
    p = argparse.ArgumentParser(description="DreamMachine TCP client")
    p.add_argument(
        "--input_image",
        nargs="*",
        default=[],
        help="本地输入图路径（0-4 张）",
    )
    p.add_argument("--target_width", type=int, default=None, help="无输入图时必须指定输出宽")
    p.add_argument("--target_height", type=int, default=None, help="无输入图时必须指定输出高")
    p.add_argument("--prompt", required=True, help="正向提示词")
    p.add_argument("--output_image", required=True, help="本地输出图路径")
    p.add_argument("--seed", type=int, default=int.from_bytes(os.urandom(4), "big"))
    p.add_argument("--steps", type=int, default=4)
    p.add_argument("--cfg", type=float, default=1.0)
    p.add_argument("--sampler_name", default="sa_solver")
    p.add_argument("--scheduler", default="beta")
    p.add_argument("--denoise", type=float, default=1.0)
    p.add_argument("--neg_prompt", default="")
    p.add_argument("--output_format", default="PNG", choices=["PNG", "JPEG", "JPG", "WEBP"])
    p.add_argument("--host", default="127.0.0.1", help="服务端地址")
    p.add_argument("--port", type=int, default=17890, help="服务端端口")
    return p.parse_args()


def main():
    args = parse_args()

    if len(args.input_image) > 4:
        raise ValueError("--input_image supports up to 4 paths")
    if not args.input_image and (args.target_width is None or args.target_height is None):
        raise ValueError("When no --input_image is provided, --target_width and --target_height are required")

    input_images_b64 = []
    for image_path in args.input_image:
        with open(image_path, "rb") as f:
            input_images_b64.append(base64.b64encode(f.read()).decode("ascii"))

    req = {
        "input_images_b64": input_images_b64,
        "target_width": args.target_width,
        "target_height": args.target_height,
        "prompt": args.prompt,
        "output_format": args.output_format,
        "seed": args.seed,
        "steps": args.steps,
        "cfg": args.cfg,
        "sampler_name": args.sampler_name,
        "scheduler": args.scheduler,
        "denoise": args.denoise,
        "neg_prompt": args.neg_prompt,
    }

    with socket.create_connection((args.host, args.port)) as conn:
        send_packet(conn, req)
        resp = recv_packet(conn)

    if not resp.get("ok"):
        raise RuntimeError(
            "Server inference failed:\n"
            f"error: {resp.get('error')}\n"
            f"traceback: {resp.get('traceback', '<none>')}"
        )

    output_b64 = resp.get("output_image_b64")
    if not output_b64:
        raise RuntimeError("Server response missing output_image_b64")

    output_bytes = base64.b64decode(output_b64)
    output_dir = os.path.dirname(os.path.abspath(args.output_image))
    os.makedirs(output_dir, exist_ok=True)
    with open(args.output_image, "wb") as f:
        f.write(output_bytes)

    result = {
        "ok": True,
        "output_image": args.output_image,
        "output_format": resp.get("output_format", args.output_format),
        "seed": resp.get("seed"),
        "width": resp.get("width"),
        "height": resp.get("height"),
        "ckpt_path": resp.get("ckpt_path"),
    }
    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
