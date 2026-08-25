#!/usr/bin/env bash

set -euo pipefail
cd "$(cd "$(dirname "$0")" && pwd)/.."

echo "===== Root formatting ====="
uv run --with nodejs-wheel npx --yes prettier@3 --check README.md .prettierrc.json .github/workflows/*.yml

for project in services/*/; do
  [ -f "${project}pyproject.toml" ] || continue
  echo "===== ${project} ====="
  (
    cd "${project}"
    uv sync --locked --dev
    uv run taplo fmt --check pyproject.toml
    uv run ruff format --check .
    uv run ruff check .
    uv run pyright
    uv run npx --yes prettier@3 --check "**/*.{json,jsonc,md,yml,yaml}"
  )
done

echo -e "\nAll checks PASSED"
