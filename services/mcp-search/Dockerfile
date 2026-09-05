FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim

WORKDIR /app
ENV PYTHONUNBUFFERED=1

# System deps for trafilatura / curl_cffi builds
RUN apt-get update && apt-get install -y --no-install-recommends gcc ca-certificates && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml README.md uv.lock ./
COPY mcp_search ./mcp_search
RUN uv sync --frozen --no-dev

EXPOSE 9932
CMD uv run --no-sync mcp-search
