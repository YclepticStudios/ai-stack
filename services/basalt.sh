#!/usr/bin/env bash
#
# Start the Basalt engine and mcp search, downloading any missing model first.

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
MODEL_DIR="$DIR/.hf-cache/basalt"
mkdir -p "$MODEL_DIR"

# "<repo> <file>" - one line per model
MODELS=(
  "jesdga/Qwen3.8-Flash-Next-Basalt Qwen3.8-FN-NVFP4-DQ6_K.basalt"
  "jesdga/Qwen3.8-27B-Basalt Qwen3.8-27B-QUASAR-NVFP4.basalt"
  "jesdga/DeepSeek-V4.1-Flash-1017-Basalt DeepSeek-V4.1-Flash-1017-UD-IQ2_XXS.basalt"
)

for entry in "${MODELS[@]}"; do
  read -r repo file <<<"$entry"
  [ -f "$MODEL_DIR/$file" ] && continue
  curl -fL -C - --retry 5 -o "$MODEL_DIR/$file.part" \
    "https://huggingface.co/$repo/resolve/main/$file"
  mv "$MODEL_DIR/$file.part" "$MODEL_DIR/$file"
done

exec docker compose -f "$DIR/docker-compose.yml" up --build --remove-orphans basalt mcp-search
