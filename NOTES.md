# Notes & gotchas

Hard‑won details from building this config. Mostly Windows‑specific, but the
ccstatusline points apply everywhere.

## ccstatusline config

- **Colors:** `"hex:RRGGBB"` — prefix `hex:` and **no `#`**. The parser does
  `substring(4)`, so `"hex:#7D56F4"` would lose a digit. Named colors (e.g.
  `"brightCyan"`) also work and auto‑convert.
- **`colorLevel: 3`** forces 24‑bit truecolor even through a non‑TTY pipe —
  required for the exact lipgloss hexes to survive when Claude Code captures the
  command output.
- **Per‑widget options live in `metadata: {}` and every value is a string:**
  `"nerdFont": "true"`, `"segments": "2"`, `"display": "progress"`, etc.
- **Reset timers** take a top‑level `"rawValue": true` to drop the `Reset:`
  label so the leading clock glyph carries the meaning.
- **Powerline backgrounds (`bgColor`) only render on a real TTY.** Through a
  non‑TTY pipe they collapse to nothing, so this config ships with foreground
  colors and `powerline.enabled: false`. Enable the ribbon live in the TUI.
- **No permission / auto‑accept‑mode widget exists** (as of ccstatusline
  2.2.19). It only reads `output_style` from the Claude Code stdin payload, so
  the closest "mode" widget is `output-style` — which usually just shows
  `default`. We dropped it from this layout.
- **Context window (line 5): the 1M limit is auto‑detected from the model id.**
  `context-window` renders `1.0M` only when the model id contains `[1m]` (e.g.
  `claude-opus-4-8[1m]`); otherwise it falls back to `200k`, and
  `context-percentage` is computed against that same denominator. So `700k`
  context shows `70%` on a 1M model but would read `100%`+ on a 200k model.
  There is **no setting to force the window size** — it is derived, not
  configured. `context-length` (current tokens) is read from the session
  transcript JSONL; with no transcript it reads `0`.
- **The context bar is `metadata.display: "slider"`** — and *only* those values
  produce a bar. `getContextSliderMode` reads `metadata.display` and accepts:
  - `"slider"` → gradient bar **+ percentage**: `▁▁▁▁▂▃▅▆▇█ 70.0%`
  - `"slider-only"` → gradient bar, no number
  - anything else (incl. `"progress"`, `"progress"`+`displayMode`, or unset) →
    `"none"` → **no bar, just the % number**. This was the "bar isn't showing"
    bug: `display: "progress"` (which works for the *usage* widgets) is silently
    ignored by `context-percentage`. Pair with `rawValue: true` to suppress the
    built‑in `Ctx Used:` label when you supply your own (here a `Context:`
    custom‑text lead).
  - **Do NOT use the `context-bar` widget in a Claude Code statusLine.** It sizes
    to the terminal width, which a *captured* statusLine command doesn't have, so
    it renders **empty**. The `slider` bar is fixed‑width and always renders.
- **No conditional / threshold‑based widgets.** ccstatusline's only `threshold`
  is the global `compactThreshold` for `flexMode: full-until-compact` (collapses
  the whole line when the terminal is narrow) — there is **no per‑widget warning
  threshold** that could, say, show a "compact now" hint only above 70%. Because
  custom‑text can't be conditional either, an always‑on `compact@70%` label was
  dropped. The **context progress bar** (line 2) is the at‑a‑glance fullness cue;
  run `/compact` when it's near full.

## Nerd Font glyph gotcha

Private‑Use‑Area glyphs (bolt `U+F0E7`, clock `U+F017`, calendar `U+F073`,
dollar `U+F155`, cog `U+F013`) get **silently stripped to empty/space by many
editors and even some shell heredocs**. The reliable way to write them is a tiny
Node script using `String.fromCodePoint` — see `scripts/apply-glyphs.mjs`.

Verify the bytes actually landed:

```bash
grep customText settings.json | od -An -tx1 | grep -oE "ef .. .."
# ef 83 a7 = U+F0E7 bolt
# ef 80 97 = U+F017 clock
# ef 81 b3 = U+F073 calendar
# ef 85 95 = U+F155 dollar
```

## Validating a render

```bash
cat preview/sample.json | ccstatusline | cat -v
```

`cat -v` shows the raw bytes; the `M-o...` triples are the UTF‑8 glyph bytes,
and `38;2;R;G;B` are the truecolor codes you can map back to the palette.
