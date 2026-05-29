#!/usr/bin/env pwsh
# Windows / PowerShell equivalent of register-mcps.sh.
# Registers all MCP servers at user scope. Safe to re-run — removes then re-adds.

$ErrorActionPreference = 'Stop'

function Remove-IfExists {
    param([string]$Name)
    $list = claude mcp list 2>$null
    if ($list -match "(?m)^${Name}:") {
        claude mcp remove $Name --scope user 2>$null | Out-Null
    }
}

function Add-Http {
    param([string]$Name, [string]$Url, [string[]]$Extra = @())
    Remove-IfExists $Name
    claude mcp add --scope user --transport http $Name $Url @Extra
    Write-Host "  added $Name"
}

function Add-Stdio {
    param([string]$Name, [string[]]$Cmd)
    Remove-IfExists $Name
    claude mcp add --scope user $Name -- @Cmd
    Write-Host "  added $Name"
}

Write-Host "Registering MCP servers..."

Add-Http betterstack https://mcp.betterstack.com
Add-Http linear      https://mcp.linear.app/mcp
Add-Http sentry      https://mcp.sentry.dev/mcp
Add-Http clickup     https://mcp.clickup.com/mcp
Add-Http github      https://api.githubcopilot.com/mcp -Extra @('--header', 'Authorization: Bearer ${GITHUB_PAT}')

Add-Stdio auth0           @('npx', '-y', '@auth0/auth0-mcp-server', 'run')
Add-Stdio chrome-devtools @('npx', '-y', 'chrome-devtools-mcp@latest', '--no-usage-statistics')

Remove-IfExists elasticsearch
claude mcp add --scope user elasticsearch -e 'ES_URL=${ES_URL}' -e 'ES_API_KEY=${ES_API_KEY}' -- npx -y @elastic/mcp-server-elasticsearch
Write-Host "  added elasticsearch"

Write-Host ""
Write-Host "Done. Run 'claude mcp list' to verify."
