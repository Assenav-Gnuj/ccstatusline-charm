#Requires -Version 5.1
<#
.SYNOPSIS
  Install the ccstatusline-charm config for Claude Code on Windows.
.DESCRIPTION
  - Ensures ccstatusline is installed globally (npm).
  - Copies settings.json to ~/.config/ccstatusline/ (backing up any existing).
  - Patches ~/.claude/settings.json so statusLine runs ccstatusline.
#>

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$home_ = $env:USERPROFILE

Write-Host '== ccstatusline-charm installer ==' -ForegroundColor Magenta

# 1. ccstatusline present?
if (-not (Get-Command ccstatusline -ErrorAction SilentlyContinue)) {
  if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    throw 'npm not found. Install Node.js first: https://nodejs.org'
  }
  Write-Host 'Installing ccstatusline globally...' -ForegroundColor Cyan
  npm install -g ccstatusline
}

# 2. Copy config (preserve UTF-8 glyph bytes via Copy-Item, not text rewrite)
$cfgDir = Join-Path $home_ '.config\ccstatusline'
$cfg    = Join-Path $cfgDir 'settings.json'
New-Item -ItemType Directory -Force -Path $cfgDir | Out-Null
if (Test-Path $cfg) {
  $bak = "$cfg.bak"
  Copy-Item $cfg $bak -Force
  Write-Host "Backed up existing config -> $bak" -ForegroundColor DarkGray
}
Copy-Item (Join-Path $repo 'settings.json') $cfg -Force
Write-Host "Installed config -> $cfg" -ForegroundColor Green

# 3. Patch Claude Code settings.json statusLine (via Node to keep JSON intact)
$claude = Join-Path $home_ '.claude\settings.json'
if (-not (Test-Path $claude)) { '{}' | Set-Content -Encoding utf8 $claude }
$node = @'
const fs=require("fs");
const f=process.argv[1];
const s=JSON.parse(fs.readFileSync(f,"utf8"));
s.statusLine={type:"command",command:"ccstatusline",padding:0,refreshInterval:10};
fs.writeFileSync(f,JSON.stringify(s,null,2)+"\n");
console.log("Patched statusLine in "+f);
'@
node -e $node $claude

Write-Host ''
Write-Host 'Done. Restart Claude Code (or wait for the next status refresh).' -ForegroundColor Magenta
Write-Host 'Tip: ensure your terminal uses a Nerd Font so the icons render.' -ForegroundColor DarkGray
