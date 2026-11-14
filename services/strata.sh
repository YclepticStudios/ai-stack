#!/usr/bin/env bash
#
# Start the Strata engine and mcp search.

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

exec docker compose -f "$DIR/docker-compose.yml" up --remove-orphans strata mcp-search
