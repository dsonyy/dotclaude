#!/usr/bin/env bash
set -euo pipefail

# Registers all MCP servers at user scope. Safe to re-run — removes then re-adds.

remove_if_exists() {
  local name="$1"
  if claude mcp list 2>/dev/null | grep -q "^$name:"; then
    claude mcp remove "$name" --scope user 2>/dev/null || true
  fi
}

add_http() {
  local name="$1" url="$2"; shift 2
  remove_if_exists "$name"
  claude mcp add --scope user --transport http "$name" "$url" "$@"
  echo "  added $name"
}

add_stdio() {
  local name="$1"; shift
  remove_if_exists "$name"
  claude mcp add --scope user "$name" -- "$@"
  echo "  added $name"
}

echo "Registering MCP servers..."

add_http betterstack  https://mcp.betterstack.com
add_http linear       https://mcp.linear.app/mcp
add_http sentry       https://mcp.sentry.dev/mcp
add_http clickup      https://mcp.clickup.com/mcp
add_http github       https://api.githubcopilot.com/mcp \
  --header 'Authorization: Bearer ${GITHUB_PAT}'

add_stdio auth0          npx -y @auth0/auth0-mcp-server run
add_stdio chrome-devtools npx -y chrome-devtools-mcp@latest --no-usage-statistics
remove_if_exists elasticsearch
claude mcp add --scope user elasticsearch -e 'ES_URL=${ES_URL}' -e 'ES_API_KEY=${ES_API_KEY}' -- npx -y @elastic/mcp-server-elasticsearch
echo "  added elasticsearch"

echo ""
echo "Done. Run 'claude mcp list' to verify."
