# AI Stack

This is a simple, local AI coding assistant configuration. It targets a system
running Ubuntu 24.04 with a single NVIDIA 5090, although it should function on a
range of Linux systems (potentially with a few tweaks). It is designed to
provide a web chat interface as well as to run a sandboxed Pi coding harness.
Determining all the right configuration options was an ordeal, so hopefully this
can serve as a starting point for other setups.

## Hosting Services

All backend inference and search services are configured in
`services/docker-compose.yml`:

- **llama-server**: [llama.cpp](https://github.com/ggml-org/llama.cpp) serves as
  the inference engine with a web chat interface (plus OpenAI-compatible
  endpoints) at [http://localhost:9931](http://localhost:9931). A web search
  tool and a JS sandbox tool are enabled by default.
- **mcp-search**: A simple self-hosted, streamable-HTTP MCP server (at
  `http://localhost:9932`) provides `search_web` (DuckDuckGo) and `fetch_page`
  (Chrome impersonation + trafilatura text extraction). It is exposed to the web
  chat via llama-server's built-in MCP proxy and to Pi via an MCP extension.

### Dependencies

- [Docker Engine](https://docs.docker.com/engine/install/)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

### Usage

The following commands can be used to build, start, and stop the server. Note
that the first access to a model will trigger its download, which may take some
time and does not provide feedback. Once launched, the web chat can be accessed
at [http://localhost:9931](http://localhost:9931).

```sh
docker compose -f services/docker-compose.yml up --build   # Build and start
docker compose -f services/docker-compose.yml down         # Stop
```

## Pi

[Pi](https://pi.dev) is the coding agent harness which utilizes the above
services. The [pi-sandbox](https://github.com/carderne/pi-sandbox) extension is
configured to sandbox the agent to avoid unapproved edits outside the workspace
or to the `.git/` folder as well as avoid unapproved network access.

### Dependencies

- [Pi](https://pi.dev/)
- [bubblewrap](https://github.com/containers/bubblewrap)
- [ripgrep](https://github.com/burntsushi/ripgrep)

### Setup

Redirect the global Pi configuration to the repo's local `pi/` folder.

```sh
mv ~/.pi ~/.pi.bak 2>/dev/null  # Backup any existing ~/.pi configuration
ln -sfn $(pwd)/pi ~/.pi         # Symlink the local pi folder to ~/.pi
```

Login to the local provider by launching Pi and running `/login llama.cpp`
followed by the address of the llama.cpp server (typically
`http://127.0.0.1:9931`).

### Usage

Run `pi` as normal from the target project directory.

```sh
cd /project/path
pi
```

## LAN mode

Everything is bound to loopback by default. To use the stack from other machines
on a trusted network (none of it is authenticated), make these changes in
`services/docker-compose.yml` and restart the services:

- **Services**: Change `127.0.0.1:9931:9931` to `0.0.0.0:9931:9931` for
  `llama-server` and `127.0.0.1:9932:9932` to `0.0.0.0:9932:9932` for
  `mcp-search`.
- **Pi**: Point each machine's `pi/agent/mcp.json` at
  `http://<this machine's LAN IP>:9932/mcp` and on each machine run
  `/login llama.cpp` in Pi, entering `http://<this machine's LAN IP>:9931`
  instead of the local URL.
