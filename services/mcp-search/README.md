# MCP Search

Simple web search and fetch MCP server. `search_web` queries DuckDuckGo and
`fetch_page` retrieves a page with Chrome browser impersonation, extracting
clean article text with trafilatura. Serves the streamable-HTTP MCP endpoint on
port 9932.

## Development

1. Ensure [`uv`](https://docs.astral.sh/uv/) is installed.
2. Run `uv sync --dev` to initialize the virtual environment.
3. Run the server with `uv run mcp-search` (listens on port 9932 by default;
   override with the `PORT` environment variable, e.g.
   `PORT=19932 uv run mcp-search`).

## Code Analysis

Run `./dev/check.sh` from the repository root, which checks this project
alongside the other subprojects. Single checks:

- `uv run ruff check .`
- `uv run pyright`
- `uv run taplo fmt --check pyproject.toml`
