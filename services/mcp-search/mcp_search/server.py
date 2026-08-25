"""Web search and fetch MCP server."""

from __future__ import annotations

import os
from typing import Any

import trafilatura
from curl_cffi import requests
from ddgs.ddgs import DDGS
from ddgs.exceptions import DDGSException
from fastmcp import FastMCP
from tenacity import (
    retry,
    retry_if_exception_type,
    stop_after_attempt,
    wait_exponential_jitter,
)

DEFAULT_PORT = 9932

mcp = FastMCP("McpSearch")


@mcp.tool()
def search_web(query: str, max_results: int = 5) -> str:
    """Search the web using DuckDuckGo."""
    try:
        return _search_with_retries(query, max_results)
    except DDGSException as e:
        return f"Search failed after retries: {e}"
    except Exception as e:
        return f"Search failed: {e}"


@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential_jitter(initial=2, max=15),
    retry=retry_if_exception_type(DDGSException),
    reraise=True,
)
def _search_with_retries(query: str, max_results: int) -> str:
    """Run a single DDGS text search; retries are handled by tenacity."""
    with DDGS() as ddgs:
        results = ddgs.text(query, max_results=max_results)
    serialized: list[dict[str, Any]] = [
        {"title": r.get("title"), "href": r.get("href"), "body": r.get("body")}
        for r in results
    ]
    return str(serialized)


@mcp.tool()
def fetch_page(url: str) -> str:
    """Fetch a webpage and extract clean text, bypassing bot protections."""
    try:
        response = requests.get(url, impersonate="chrome", timeout=15)
    except Exception as e:
        return f"Fetch failed: {e}"
    text = trafilatura.extract(response.content, url=url)
    return text or "Error: Could not extract readable content."


def main() -> None:
    """Run the MCP server over the streamable-HTTP transport."""
    port = int(os.environ.get("PORT", str(DEFAULT_PORT)))
    mcp.run(transport="streamable-http", host="0.0.0.0", port=port)


if __name__ == "__main__":
    main()
