# DreamMachine

DreamMachine 是一个本地图片生成/编辑工具链：
- 客户端：Qt 6（桌面默认 QWidget，支持 QML 预览/移动端 UI）
- 服务端：Python + ComfyUI（TCP 推理服务）

![DreamMachine Screenshot](dreammachine_20260311_101829.png)

## 快速开始（先跑通）

### 1. 拉取代码与子模块

```bash
git clone https://github.com/QQxiaoming/DreamMachine.git
cd DreamMachine
git submodule update --init --recursive
```

### 2. 准备 Python 环境（服务端）

```bash
python3 -m venv server/ComfyUI/.venv
source server/ComfyUI/.venv/bin/activate
pip install -U pip
pip install -r server/ComfyUI/requirements.txt
```

### 3. 启动服务端（Fake 模式，无需模型）

```bash
source server/ComfyUI/.venv/bin/activate
python server/DreamMachine_server.py --host 127.0.0.1 --port 17890 --fake_mode
```

### 4. 构建并启动桌面客户端（Linux）

```bash
cmake -S client -B client/build/local -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build client/build/local -j
./client/build/local/DreamMachine
```

客户端默认连接 `127.0.0.1:17890`，与上面的服务端参数一致。

## 项目结构

```text
DreamMachine/
├─ client/                  # Qt 客户端（桌面 + 移动端）
│  ├─ qml/                  # QML 页面与组件
│  └─ src/                  # C++ 业务逻辑
├─ server/
│  ├─ DreamMachine_server.py# DreamMachine TCP 推理服务
│  └─ ComfyUI/              # ComfyUI 子模块（推理与节点）
├─ script/
│  ├─ DreamMachine.py       # TCP 测试客户端脚本
│  └─ convert-ipa.sh        # .app 转 .ipa 辅助脚本
└─ dreammachine_preset.json # 预设示例
```

## 架构概览

```text
Qt Client (Desktop / QML)
        |
        | TCP (4-byte length header + JSON body)
        v
DreamMachine_server.py
        |
        v
ComfyUI Nodes + Checkpoint
```

## 服务端说明

`server/DreamMachine_server.py` 主要参数：
- `--host`：监听地址，默认 `127.0.0.1`
- `--port`：监听端口，默认 `17890`
- `--ckpt_path`：模型路径（真实推理模式必须）
- `--cpu_mode`：强制 CPU 推理
- `--fake_mode`：跳过模型加载，返回合成图片（联调推荐）

### 真实推理模式示例

```bash
source server/ComfyUI/.venv/bin/activate
python server/DreamMachine_server.py \
  --host 127.0.0.1 \
  --port 17890 \
  --ckpt_path /absolute/path/to/your_model.safetensors
```

说明：
- 使用真实推理模式时，请确保模型文件位于 ComfyUI 可访问路径。
- 若显存不足可加 `--cpu_mode`（速度会明显下降）。

## 客户端说明

### 桌面 UI 与 QML 预览

默认启动桌面 QWidget UI：

```bash
./client/build/local/DreamMachine
```

如需在桌面上预览移动端 QML UI：

```bash
./client/build/local/DreamMachine --qml
```

### 连接配置

客户端可配置：
- 服务端地址 `host`
- 服务端端口 `port`
- 推理参数（prompt、seed、steps、cfg、sampler、scheduler、denoise 等）
- 输入图（最多 4 张）与输出格式（PNG/JPEG/WEBP）

## 命令行联调脚本

`script/DreamMachine.py` 可直接发起一次请求，便于排查客户端之外的问题。

### 无输入图（必须指定目标分辨率）

```bash
python script/DreamMachine.py \
  --prompt "a cinematic portrait" \
  --target_width 768 \
  --target_height 1024 \
  --output_image ./output/test.png \
  --host 127.0.0.1 \
  --port 17890
```

### 使用输入图（最多 4 张）

```bash
python script/DreamMachine.py \
  --input_image ./input/a.png ./input/b.png \
  --prompt "keep identity, change outfit" \
  --output_image ./output/test_edit.png
```

## 预设与可复现

DreamMachine 支持保存/加载预设，并在生成 PNG 中嵌入预设 JSON（键名为 `dreammachine_preset_json`），方便复现参数与分享流程。

常见预设字段包括：
- 输入图路径
- target_width / target_height
- prompt / neg_prompt
- seed / steps / cfg
- sampler_name / scheduler / denoise
- output_format
- host / port

## iOS / 打包补充

- iOS 相关配置位于 `client/platform/ios/`。
- 可使用 `script/convert-ipa.sh` 将 `.app` 目录打包为 `.ipa`（辅助脚本）。
- 如需 macOS DMG，可查看 `script/create-dmg/build-dmg.sh`。

## 常见问题

### 1) 报错 `Cannot locate ComfyUI root`

原因：服务端未找到 ComfyUI 根目录。

解决：
- 确保已初始化子模块：`git submodule update --init --recursive`
- 从仓库根目录运行服务端，或设置环境变量：

```bash
export COMFYUI_ROOT=$(pwd)/server/ComfyUI
```

### 2) 客户端提示连接失败（Connection refused / timeout）

检查：
- 服务端是否在运行
- `host` / `port` 是否一致
- 本机防火墙是否拦截

### 3) 真实推理启动失败（checkpoint 加载错误）

检查：
- `--ckpt_path` 是否为有效绝对路径
- 模型文件是否可读
- 依赖与 ComfyUI 节点是否安装完整

## 开发建议

- 先用 `--fake_mode` 验证链路（网络、参数、UI）再切真实模型。
- 改动协议字段时，同步更新：
  - `client/src/inference_client.cpp`
  - `server/DreamMachine_server.py`
  - `script/DreamMachine.py`
