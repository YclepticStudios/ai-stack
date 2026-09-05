# AI Stack

This is a simple, local AI coding assistant setup. It is built for Ubuntu 24.04
running with a single NVIDIA 5090, although with some modifications it can be
made to run on other systems. Containerized inference engines and MCP servers
are provided in the services folder, while the harnesses folder provides
configurations for running preconfigured, sandboxed coding harnesses.

This is an evolving configuration as I experiment with different tools and is
provided to hopefully give others a jump-start on setting up their own
configurations.

## Services

- **llama-server**: [llama.cpp](https://github.com/ggml-org/llama.cpp) is one
  inference engine option, serving a web chat interface (plus OpenAI-compatible
  endpoints) at [http://localhost:9931](http://localhost:9931).
- **ninfer**: [NInfer](https://github.com/Neroued/ninfer) is an alternative
  inference engine, serving OpenAI- and Anthropic-compatible endpoints at the
  same address (API only, no web chat). It has fewer options and less
  compatibility but is notably faster.
- **mcp-search**: A simple self-hosted, streamable-HTTP MCP server (at
  `http://localhost:9932`) provides `search_web` (DuckDuckGo) and `fetch_page`
  (Chrome impersonation + trafilatura text extraction).

Note: The two inference engines are alternatives: both bind port 9931 and want
the whole GPU. Start only one of them, not both.

### Dependencies

- [Docker Engine](https://docs.docker.com/engine/install/)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
- [uv](https://docs.astral.sh/uv/)

### Usage

Run one of the following commands to control the server:

```sh
services/llamacpp.sh   # Build and start (llama.cpp)
services/ninfer.sh     # Build and start (NInfer)
services/down.sh       # Stop everything
```

Both servers provide OpenAI compatible endpoints at `http://127.0.0.1:9931/v1`.
The llama.cpp server additionally provides a web chat at
[http://localhost:9931](http://localhost:9931).

Note: First use may take a while to start since the models must be downloaded
and NInfer compiled from source.

## Pi

[Pi](https://pi.dev) is the coding agent harness which utilizes the above
services. The [pi-sandbox](https://github.com/carderne/pi-sandbox) extension is
configured to sandbox the agent, blocking unapproved edits outside the workspace
or to `.git/`, and unapproved network access.

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
`http://127.0.0.1:9931`). The `ninfer` provider is configured the same way
(`/login ninfer`, same address); to make it the default, set `defaultProvider`
to `ninfer` in `pi/agent/settings.json`.

### Usage

Run `pi` as normal from the target project directory.

```sh
cd /project/path
pi
```

## OpenCode

[OpenCode](https://opencode.ai) is a second, TUI based coding agent. It is
launched through `opencode/oc`, a small wrapper which runs the entire instance
inside a [bubblewrap](https://github.com/containers/bubblewrap) sandbox: the
whole filesystem is read-only except the project directory (with `.git/` kept
read-only), a fresh private `/tmp`, and OpenCode's own state directories.
Network access is unrestricted. The repo's `opencode.jsonc` is mapped in as the
instance config when launched via `oc`.

### Dependencies

- [OpenCode](https://opencode.ai)
- [bubblewrap](https://github.com/containers/bubblewrap)

### Setup

Link the sandboxed launcher onto your PATH.

```sh
ln -sfn $(pwd)/opencode/oc ~/.local/bin/oc
```

### Usage

Run `oc` from the target project directory, or pass the directory as the first
argument. Further arguments are passed through to `opencode`.

```sh
cd /project/path
oc                  # or: oc /project/path
```

## LAN mode

Everything is bound to loopback by default. To use the stack from other machines
on a trusted network (none of it is authenticated), make these changes in
`services/docker-compose.yml` and restart the services:

- **Services**: Change `127.0.0.1:9931:9931` to `0.0.0.0:9931:9931` for the
  inference engine (`llama-server` or `ninfer`) and `127.0.0.1:9932:9932` to
  `0.0.0.0:9932:9932` for `mcp-search`.
- **Pi**: Point each machine's `pi/agent/mcp.json` at
  `http://<this machine's LAN IP>:9932/mcp` and on each machine run
  `/login llama.cpp` (or `/login ninfer`) in Pi, entering
  `http://<this machine's LAN IP>:9931` instead of the local URL.
