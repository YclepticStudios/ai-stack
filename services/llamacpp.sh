#!/usr/bin/env bash
#
# Start the llama.cpp engine and mcp search.

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

exec docker compose -f "$DIR/docker-compose.yml" up --build --remove-orphans llama-server mcp-search
