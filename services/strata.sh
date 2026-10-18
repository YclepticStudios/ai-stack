#!/usr/bin/env bash
#
# Start the Strata engine and mcp search, and download the model if missing.

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
MODEL_DIR="$DIR/.hf-cache/strata"
MODEL="$MODEL_DIR/qwen-nvfp4-gptq/pack/experts.bin"
REVISION=640a1db97446ddd5e89d2b70ecd0297987192c93

if [ ! -f "$MODEL" ]; then
  uvx hf download Maximilian228/Qwen3.8-Flash-Next-NVFP4-GPTQ-Strata --revision "$REVISION" --local-dir "$MODEL_DIR/qwen-nvfp4-gptq" --include "*.gguf" --include "pack/*" --include "mtp/*"
  uvx hf download ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF mmproj-Qwen3.8-Flash-Next-BF16.gguf --local-dir "$MODEL_DIR"
fi

exec docker compose -f "$DIR/docker-compose.yml" up --build --remove-orphans strata mcp-search
