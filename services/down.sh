#!/usr/bin/env bash
#
# Stop all services.

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

exec docker compose -f "$DIR/docker-compose.yml" down --remove-orphans
