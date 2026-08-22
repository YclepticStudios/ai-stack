# ai-stack

Local AI stack: [pi](https://pi.dev) (terminal coding agent) sandboxed with
bubblewrap, served by a local llama.cpp router in Docker on the GPU. Models
are GGUFs, auto-downloaded on first use; nothing here talks to a cloud
provider.

- `pi/` - client side: `phi` (sandboxed launcher) and `agent/` (pi state, kept in the repo)
- `opencode/` - legacy opencode client (`oc` launcher, `opencode.jsonc`); superseded by pi
- `llamacpp/` - server side: `docker-compose.yml`, `preset.ini` (model presets), `ui-config.json` (web UI defaults)

## Prerequisites

- **Docker Engine**: https://docs.docker.com/engine/install/
- **NVIDIA Container Toolkit**: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
- **bubblewrap**: `sudo apt install bubblewrap`
- **Node.js 22.19+**: https://nodejs.org (pi runtime)
- **pi**: `npm install -g --ignore-scripts @earendil-works/pi-coding-agent` (or `curl -fsSL https://pi.dev/install.sh | sh`)

## Setup and usage

```sh
# From the repo root: link the sandboxed launcher, pull the image
mkdir -p ~/.local/bin
ln -sfn $(pwd)/pi/phi ~/.local/bin/phi
docker compose -f llamacpp/docker-compose.yml pull

# Start the llama.cpp server
docker compose -f llamacpp/docker-compose.yml up -d

cd some-project
phi             # or: phi [initial message...]
```

### Web search

Pi has no built-in web search; it uses an extension. Install it once (runs
inside the sandbox, registers the package globally; works out of the box via
keyless Exa MCP — the same provider this stack already uses, no API key):

```sh
phi install npm:pi-web-access
```

### Models

The local router feeds pi's built-in llama.cpp provider (wired via
`LLAMA_BASE_URL` in the launcher): `qwen3.8:27b` (172K ctx, MTP) is loaded on
boot and is the default; `muse-glimmer:30b` (131K ctx, DFlash) and downloads
via `/llama`, switch with `/model` (or Ctrl+P), thinking level with Shift+Tab.

### Config

Pi runs with its state dir pointed at `pi/agent` (repo-local, like
`llamacpp/.hf-cache`). `agent/settings.json` is committed — edit it here and
changes show up in git; `/settings` edits it in place too. Everything pi
writes at runtime (trust, sessions, installed packages) also lands there and
is gitignored. The one exception is `agent/auth.json`: it is committed as a
pre-seeded llama.cpp login (router URL only, no secret) so a fresh clone
works without `/login`. `agent/models-store.json` is a regenerable catalog
cache and stays gitignored.

## Operations

```sh
docker compose -f llamacpp/docker-compose.yml up -d      # start
docker compose -f llamacpp/docker-compose.yml down       # stop
docker compose -f llamacpp/docker-compose.yml restart    # restart (reload models)
```

Upgrade: bump the image tag in `llamacpp/docker-compose.yml`, then
re-run `pull` and `up -d` from Setup (both idempotent).
