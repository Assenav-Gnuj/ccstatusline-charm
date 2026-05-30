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
