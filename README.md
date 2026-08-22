# ai-stack

Local AI stack: OpenCode (sandboxed with bubblewrap) served by a local llama.cpp
router in Docker on the GPU. Models are GGUFs, auto-downloaded on first use;
nothing here talks to a cloud provider.

- `opencode/` - client side: `opencode.jsonc` (providers/models) and `oc` (sandboxed launcher)
- `llamacpp/` - server side: `docker-compose.yml`, `preset.ini` (model presets), `ui-config.json` (web UI defaults)

## Prerequisites

- **Docker Engine**: https://docs.docker.com/engine/install/
- **NVIDIA Container Toolkit**: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
- **bubblewrap**: `sudo apt install bubblewrap`
- **OpenCode**: `curl -fsSL https://opencode.ai/install | bash` (stand-alone installer, binary lands in `~/.opencode/bin/`)

## Setup and usage

```sh
# From the repo root: link the sandboxed launcher, pull the image
mkdir -p ~/.local/bin
ln -sfn $(pwd)/opencode/oc ~/.local/bin/oc
docker compose -f llamacpp/docker-compose.yml pull

# Start the llama.cpp server
docker compose -f llamacpp/docker-compose.yml up -d

cd some-project
oc             # or: oc /path/to/project
```

Models are auto-downloaded to `llamacpp/.hf-cache` (gitignored) on first use, so
the first start of a model may take a while. To change models or quants, edit
`llamacpp/preset.ini`.

Models (via `/models`): `llama.cpp/qwen3.8:27b` (172K ctx, MTP) and
`llama.cpp/muse-glimmer:30b` (131K ctx, DFlash). Variants: `:none :low :medium :high :xhigh`. Only one model is resident at a time (`--models-max 1`).
Web search works out of the box via Exa, no API key.

## Operations

```sh
docker compose -f llamacpp/docker-compose.yml up -d      # start
docker compose -f llamacpp/docker-compose.yml down       # stop
docker compose -f llamacpp/docker-compose.yml restart    # restart (reload models)
```

Upgrade: bump the image tag in `llamacpp/docker-compose.yml`, then
re-run `pull` and `up -d` from Setup (both idempotent).
