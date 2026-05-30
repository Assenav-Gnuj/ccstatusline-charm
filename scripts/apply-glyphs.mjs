#!/usr/bin/env node
// Set the Nerd Font Private-Use-Area glyphs on the custom-text widgets reliably.
//
// Why this exists: many editors and shell heredocs silently strip PUA glyphs to
// empty strings. Writing them via String.fromCodePoint guarantees correct bytes.
//
// Usage:
//   node scripts/apply-glyphs.mjs [path/to/settings.json]
// Defaults to ./settings.json in the repo root.

import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const file = process.argv[2] ?? fileURLToPath(new URL('../settings.json', import.meta.url));

// widget id -> Nerd Font codepoint (trailing space added automatically)
const GLYPHS = {
  l2: 0xf0e7, // bolt      -> session line
  k1: 0xf017, // clock     -> session reset
  l3: 0xf073, // calendar  -> weekly line
  k2: 0xf017, // clock     -> weekly reset
  l4: 0xf155, // dollar    -> cost line
};

const data = JSON.parse(readFileSync(file, 'utf8'));
let n = 0;
for (const line of data.lines) {
  for (const w of line) {
    if (GLYPHS[w.id]) {
      // " <glyph> " for the clocks (space on both sides), "<glyph> " for leads
      const isClock = w.id === 'k1' || w.id === 'k2';
      const g = String.fromCodePoint(GLYPHS[w.id]);
      w.customText = isClock ? ` ${g} ` : `${g} `;
      n++;
    }
  }
}

writeFileSync(file, JSON.stringify(data, null, 2) + '\n');
console.log(`Set ${n} glyph(s) in ${file}`);
