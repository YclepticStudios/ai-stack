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
time. Once launched, the web chat can be accessed at
[http://localhost:9931](http://localhost:9931).

```sh
docker compose -f services/docker-compose.yml up --build   # Build and start
docker compose -f services/docker-compose.yml down         # Stop
```

## Pi

[Pi](https://pi.dev) is the coding agent harness side of the stack, which
utilizes `llama.cpp` above. It is run through `phi`, a small launcher that wraps
`pi` in a bubblewrap sandbox to limit its access to the host system. By default,
this will restrict write access to the launch directory (with the `.git/` folder
read-only) as well as hide some other sensitive directories like the user's
home. All `pi` configuration is redirected to `./pi/agent` when launched with
`phi`.

### Dependencies

- [Pi](https://pi.dev/)
- [bubblewrap](https://github.com/containers/bubblewrap)

### Setup

From the repo root, run the following to create a symlink to `phi` in
`~/.local/bin/`. If that directory does not exist or is not on the PATH, create
it and add it to the PATH.

```sh
ln -sfn $(pwd)/pi/phi ~/.local/bin/phi
```

### Usage

Run `phi` to start a session, optionally passing a project directory as the
first argument (defaults to the current directory; directories above `$HOME` are
rejected).

```sh
phi                # Start a session in the current directory
phi /project/path  # Start a session in a specific directory
```

## LAN mode

Everything is bound to loopback by default. To use the stack from other machines
on a trusted network (none of it is authenticated), make these changes in
`services/docker-compose.yml` and restart the services:

- **Web Chat**: Change `127.0.0.1:9931:9931` to `0.0.0.0:9931:9931` on
  `llama-server`.
- **Pi**: Change `127.0.0.1:9932:9932` to `0.0.0.0:9932:9932` on `mcp-search`
  and point each machine's `pi/agent/mcp.json` at
  `http://<this machine's LAN IP>:9932/mcp`.
