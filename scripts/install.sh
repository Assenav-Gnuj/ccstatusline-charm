#!/usr/bin/env bash
# Install the ccstatusline-charm config for Claude Code on macOS / Linux.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cfg_dir="${XDG_CONFIG_HOME:-$HOME/.config}/ccstatusline"
cfg="$cfg_dir/settings.json"
claude="$HOME/.claude/settings.json"

echo "== ccstatusline-charm installer =="

# 1. ccstatusline present?
if ! command -v ccstatusline >/dev/null 2>&1; then
  command -v npm >/dev/null 2>&1 || { echo "npm not found. Install Node.js first."; exit 1; }
  echo "Installing ccstatusline globally..."
  npm install -g ccstatusline
fi

# 2. Copy config (cp preserves the UTF-8 glyph bytes)
mkdir -p "$cfg_dir"
if [ -f "$cfg" ]; then
  cp "$cfg" "$cfg.bak"
  echo "Backed up existing config -> $cfg.bak"
fi
cp "$repo/settings.json" "$cfg"
echo "Installed config -> $cfg"

# 3. Patch Claude Code settings.json statusLine via Node (keeps JSON intact)
mkdir -p "$(dirname "$claude")"
[ -f "$claude" ] || echo '{}' > "$claude"
node -e '
const fs=require("fs");
const f=process.argv[1];
const s=JSON.parse(fs.readFileSync(f,"utf8"));
s.statusLine={type:"command",command:"ccstatusline",padding:0,refreshInterval:10};
fs.writeFileSync(f,JSON.stringify(s,null,2)+"\n");
console.log("Patched statusLine in "+f);
' "$claude"

echo ""
echo "Done. Restart Claude Code (or wait for the next status refresh)."
echo "Tip: ensure your terminal uses a Nerd Font so the icons render."
