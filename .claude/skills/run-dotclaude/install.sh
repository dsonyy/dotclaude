#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CLAUDE="$HOME/.claude"

echo "dotclaude: installing from $REPO"

mkdir -p "$CLAUDE"

link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "  ok      $dst"
  elif [ -L "$dst" ]; then
    echo "  relink  $dst"
    ln -sf "$src" "$dst"
  elif [ -e "$dst" ]; then
    echo "  backup  $dst -> $dst.bak"
    mv "$dst" "$dst.bak"
    ln -s "$src" "$dst"
  else
    ln -s "$src" "$dst"
    echo "  linked  $dst -> $src"
  fi
}

link "$REPO/.claude/settings.json" "$CLAUDE/settings.json"
link "$REPO/.claude/agents"        "$CLAUDE/agents"
link "$REPO/.claude/skills"        "$CLAUDE/skills"
link "$REPO/.claude.json"          "$HOME/.claude.json"

# Generate ding.wav if somehow missing
WAV="$REPO/.claude/sounds/ding.wav"
if [ ! -f "$WAV" ]; then
  echo "  generating ding.wav..."
  python3 "$REPO/.claude/sounds/play.py"
fi

echo ""
echo "Symlinks done. Register MCP servers with:"
echo "  bash $REPO/.claude/skills/run-dotclaude/register-mcps.sh"
