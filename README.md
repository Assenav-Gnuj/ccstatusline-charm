# ccstatusline-charm

A [ccstatusline](https://github.com/sirmalloc/ccstatusline) configuration for
[Claude Code](https://docs.claude.com/en/docs/claude-code) themed with the
official [Charm / lipgloss](https://github.com/charmbracelet/lipgloss)
bright-shock palette.

Four compact lines, each led by a Nerd Font icon, with usage bars, reset
countdowns, cost, and thinking effort.

```text
 Model: Opus 4.8 | ~/charm/clawd-pet   main ✓ | 26%
 Tokens: 700.0k / 1.0M [██████████░░░░] 70%
 Session: [████████░░░░░░░░░░░░░░░░░░░░░░░░] 26.0%   16m
 Weekly:  [██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 7.0%    4d 8hr 46m
 Cost: $2.45 |  Thinking: default
```

*(icons —  gauge,  bolt,  calendar,  dollar,  clock,  git,  bulb
 — render with a Nerd Font)*

## Layout

| Line | Lead icon | Content |
|------|-----------|---------|
| 1 | model glyph | model · cwd (2 segments) · git branch +  changes · context % |
| 2 |  gauge | **Tokens**: used **/ 1M** window + **progress bar** + % |
| 3 |  bolt | 5‑hour **session** usage bar +  clock + block reset countdown |
| 4 |  calendar | **weekly** usage bar +  clock + weekly reset countdown |
| 5 |  dollar | session **cost** ·  **thinking effort** |

Usage bars and reset timers come from ccstatusline's OAuth usage API (the same
numbers as `/usage` inside Claude Code). The Tokens line reads live context usage
from the session transcript; the **1M window is detected from the `[1m]` model
id** (Claude Code's 1M‑context Opus). On a 200k model it shows `/ 200k`.

## Palette (lipgloss `examples/layout/main.go`)

| Token | Hex | Used for |
|-------|-----|----------|
| purple | `#7D56F4` | model |
| violet | `#A550DF` | cwd |
| mint | `#73F59F` | git branch · session bar · cost label |
| hot‑pink | `#FF5F87` | git changes |
| shock‑pink | `#F25D94` | weekly bar · thinking effort |
| pure‑blue | `#0000FF` | cost |
| cyan | `#14F9D5` | context % · clocks · reset timers |
| lime | `#EDFF82` | line lead icons |
| subtle | `#383838` | separators |

Colors are stored as `"hex:RRGGBB"` (note: **no `#`** — ccstatusline's parser
strips the first 4 chars of `hex:`). `colorLevel: 3` forces truecolor even
through a non‑TTY pipe.

## Requirements

- [Claude Code](https://docs.claude.com/en/docs/claude-code)
- Node.js + npm (for `ccstatusline`)
- A **Nerd Font** in your terminal for the glyphs — e.g.
  [Monoid Nerd Font](https://www.nerdfonts.com/font-downloads) with
  *Symbols Nerd Font* as fallback.

## Install

### Windows (PowerShell)

```powershell
./scripts/install.ps1
```

### macOS / Linux

```bash
./scripts/install.sh
```

The installer will:

1. `npm install -g ccstatusline` (if not already present).
2. Back up and copy `settings.json` to `~/.config/ccstatusline/settings.json`.
3. Patch `~/.claude/settings.json` so `statusLine` runs `ccstatusline`.

### Manual

```bash
cp settings.json ~/.config/ccstatusline/settings.json
```

and add this to `~/.claude/settings.json`:

```json
"statusLine": { "type": "command", "command": "ccstatusline", "padding": 0, "refreshInterval": 10 }
```

## Validate

Render the bundled sample payload (emits ANSI to your terminal):

```bash
cat preview/sample.json | ccstatusline
```

## Customize

Easiest: run `ccstatusline` in your terminal for the interactive TUI (toggle
Powerline ribbons, pick widgets, recolor).

To script color/glyph changes safely, use `scripts/apply-glyphs.mjs` — many
editors silently drop Private‑Use‑Area Nerd Font glyphs, so this repo sets them
via `String.fromCodePoint`. See [NOTES.md](NOTES.md) for the hard‑won gotchas.

## License

MIT — see [LICENSE](LICENSE).
