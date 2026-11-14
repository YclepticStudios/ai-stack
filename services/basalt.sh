#!/usr/bin/env bash
#
# Start the Basalt engine and mcp search, and download the model if missing.

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
MODEL_DIR="$DIR/.hf-cache/basalt"

MODEL="$MODEL_DIR/Qwen3.8-FN-NVFP4-DQ6_K.basalt"
if [ ! -f "$MODEL" ]; then
  uvx hf download jesdga/Qwen3.8-Flash-Next-Basalt Qwen3.8-FN-NVFP4-DQ6_K.basalt --local-dir "$MODEL_DIR"
fi

MODEL="$MODEL_DIR/Qwen3.8-27B-NVFP4.basalt"
if [ ! -f "$MODEL" ]; then
  uvx hf download jesdga/Qwen3.8-27B-Basalt Qwen3.8-27B-NVFP4.basalt --local-dir "$MODEL_DIR"
fi

MODEL="$MODEL_DIR/DeepSeek-V4.1-Flash-1017-UD-IQ1_M.basalt"
if [ ! -f "$MODEL" ]; then
  uvx hf download jesdga/DeepSeek-V4.1-Flash-1017-Basalt DeepSeek-V4.1-Flash-1017-UD-IQ1_M.basalt --local-dir "$MODEL_DIR"
fi

exec docker compose -f "$DIR/docker-compose.yml" up --build --remove-orphans basalt mcp-search
