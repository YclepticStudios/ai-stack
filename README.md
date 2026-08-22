# AI Stack

This is my personal local AI coding assistant configuration. It targets a system
with a single NVIDIA 5090 running Ubuntu 24. It is designed to provide a web
chat interface as well as to run a (somewhat) isolated Pi coding harness.
Finding all the right configuration options to get stuff operating nicely was
rather painful, so hopefully this can serve as a starting point for others.

## llama.cpp

[llama.cpp](https://github.com/ggml-org/llama.cpp) serves as the inference
engine and provides a clean and functional web chat interface to use alongside
its OpenAI compatible endpoints. By default, a web search tool and a JS sandbox
tool are enabled within the web chat.

### Dependencies

- [Docker Engine](https://docs.docker.com/engine/install/)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

### Setup

From the repo root run the following:

```sh
docker compose -f llamacpp/docker-compose.yml pull
```

### Usage

The following commands can be used to start and stop the server. Note that the
first access to a model will trigger its download which may take some time. Once
launched, the web chat can be accessed at
[http://localhost:9931](http://localhost:9931).

```sh
docker compose -f llamacpp/docker-compose.yml up -d   # Start and detach
docker compose -f llamacpp/docker-compose.yml down    # Stop
```

## pi

[pi](https://pi.dev) is the coding agent harness side of the stack. It is run
through `phi`, a small launcher that wraps `pi` in a bubblewrap sandbox to limit
its access to the host system. By default this will restrict write access to the
launch directory (with the `.git/` folder readonly) as well as hiding some other
sensitive directories like the users home.

### Dependencies

- [Node.js](https://nodejs.org) (22.19+)
- [pi](https://pi.dev/docs/latest/quickstart)
- [bubblewrap](https://github.com/containers/bubblewrap)

### Setup

From the repo root run the following to link the `phi` launcher into your PATH
(`~/.local/bin` must be on the PATH):

```sh
mkdir -p ~/.local/bin
ln -sfn $(pwd)/pi/phi ~/.local/bin/phi
```

### Usage

Run `phi` to start a session, optionally passing a project directory as the
first argument (defaults to the current directory; directories under `$HOME` are
rejected).

```sh
phi              # Start a session in the current directory
phi /path/project  # Start a session in a specific directory
```
