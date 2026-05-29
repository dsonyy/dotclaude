#!/usr/bin/env pwsh
# Windows / PowerShell equivalent of install.sh.
# Dirs are linked with junctions (no admin needed). Files are linked with
# symlinks, which require either admin or Developer Mode enabled
# (Settings -> Privacy & security -> For developers).

$ErrorActionPreference = 'Stop'

$Repo   = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$Claude = Join-Path $HOME '.claude'

Write-Host "dotclaude: installing from $Repo"

New-Item -ItemType Directory -Force -Path $Claude | Out-Null

function Link {
    param(
        [string]$Src,
        [string]$Dst,
        [ValidateSet('SymbolicLink', 'Junction')]
        [string]$Kind
    )

    $existing = Get-Item -LiteralPath $Dst -Force -ErrorAction SilentlyContinue

    if ($existing -and $existing.LinkType -and $existing.Target -eq $Src) {
        Write-Host "  ok      $Dst"
        return
    }
    elseif ($existing -and $existing.LinkType) {
        Write-Host "  relink  $Dst"
        Remove-Item -LiteralPath $Dst -Force -Recurse
    }
    elseif ($existing) {
        Write-Host "  backup  $Dst -> $Dst.bak"
        Move-Item -LiteralPath $Dst -Destination "$Dst.bak" -Force
    }

    New-Item -ItemType $Kind -Path $Dst -Target $Src | Out-Null
    if (-not $existing) { Write-Host "  linked  $Dst -> $Src" }
}

Link -Src (Join-Path $Repo '.claude\settings.json') -Dst (Join-Path $Claude 'settings.json') -Kind SymbolicLink
Link -Src (Join-Path $Repo '.claude\agents')        -Dst (Join-Path $Claude 'agents')        -Kind Junction
Link -Src (Join-Path $Repo '.claude\skills')        -Dst (Join-Path $Claude 'skills')        -Kind Junction
Link -Src (Join-Path $Repo '.claude.json')          -Dst (Join-Path $HOME '.claude.json')    -Kind SymbolicLink

# Generate ding.wav if somehow missing
$Wav = Join-Path $Repo '.claude\sounds\ding.wav'
if (-not (Test-Path -LiteralPath $Wav)) {
    Write-Host "  generating ding.wav..."
    python3 (Join-Path $Repo '.claude\sounds\play.py')
}

Write-Host ""
Write-Host "Symlinks done. Register MCP servers with:"
Write-Host "  pwsh $Repo\.claude\skills\run-dotclaude\register-mcps.ps1"
