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

## Harnesses

- **opencode**: [OpenCode](https://opencode.ai) TUI agent (config in
  `harnesses/config/opencode/`).
- **pi**: [Pi](https://pi.dev) coding agent (config in `harnesses/config/pi/`).

Both are preconfigured for the local inference engines at
`http://127.0.0.1:9931`. They can be launched with the `sbx` script to disable
writes outside the working directory and to `.git/` as well as to mask `~/.ssh`.

### Dependencies

- [bubblewrap](https://github.com/containers/bubblewrap)
- [OpenCode](https://opencode.ai)
- [Pi](https://pi.dev/)

### Setup

Link the launcher onto your PATH:

```sh
ln -sfn $(pwd)/harnesses/sbx ~/.local/bin/sbx
```

### Usage

Run the desired harness from the target project directory; further arguments are
passed through to the harness:

```sh
cd /project/path
sbx pi
sbx opencode
```

## LAN mode

Everything is bound to loopback by default. To use the stack from other machines
on a trusted network (none of it is authenticated), expose the services on the
stack machine and point each client machine's harness configs at it:

- **Services**: In `services/docker-compose.yml`, change `127.0.0.1:9931:9931`
  to `0.0.0.0:9931:9931` for the inference engine (`llama-server` or `ninfer`)
  and `127.0.0.1:9932:9932` to `0.0.0.0:9932:9932` for `mcp-search`, then
  restart the services.
- **Harnesses**: On each client machine, set the `baseURL` fields in
  `harnesses/config/opencode/opencode.jsonc` and the `baseUrl` fields in
  `harnesses/config/pi/models.json` to `http://<stack machine IP>:9931/v1`, and
  the `url` in `harnesses/config/pi/mcp.json` to
  `http://<stack machine IP>:9932/mcp`.
