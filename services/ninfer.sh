#!/usr/bin/env bash
#
# Start the NInfer engine and mcp search, and download the model if missing.

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
MODEL_DIR="$DIR/.hf-cache"
MODEL="$MODEL_DIR/qwen3_8_27b_nvfp4.ninfer"

if [ ! -f "$MODEL" ]; then
  uvx hf download neroued/Qwen3.8-27B-nvfp4-NInfer qwen3_8_27b_nvfp4.ninfer --local-dir "$MODEL_DIR"
fi

exec docker compose -f "$DIR/docker-compose.yml" up --build --remove-orphans ninfer mcp-search
