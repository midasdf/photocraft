# Photoshop oracle corpus

256 small PSDs authored **from scratch** with Adobe Photoshop 2026 (27.10.0, macOS) by the
ExtendScript generator in [`tools/photoshop-oracles/generate.jsx`](../../tools/photoshop-oracles/generate.jsx).
Every file is saved with **Maximize Compatibility** on, so its merged composite is Photoshop's own
rendering of the layer stack: the oracle our importer, compositor, smart-filter stack and text
engine are compared with.

| Directory | Files | What it exercises |
|---|---:|---|
| `smart-filters/` | 30 | Smart objects (128×128) with smart filters: Gaussian Blur (r 1.5/4/20), Unsharp Mask, Add Noise (uniform, gaussian mono), Motion Blur, High Pass, Median, Minimum, Maximum, Box Blur, Emboss, Mosaic, Levels, Curves, Shadows/Highlights; filter masks (gradient, hard, ellipse); filter blend mode/opacity (Multiply, Screen, Difference, Overlay); stacked filters; transformed smart objects; layer opacity/blend over a smart object |
| `effects/` | 37 | Bevel & Emboss in every style (outer, inner, emboss, pillow, stroke emboss) × technique (smooth, chisel hard, chisel soft); direction down, soften, angle/altitude/depth; contours and gloss contours (with and without anti-aliasing, ranges); stroke emboss with inside/center strokes; Satin (default, inverted with contour, Screen); outer glow (soft, precise + spread, contour, gradient); inner glow (edge, center + choke, contour); a combination |
| `text/` | 54 | Point and paragraph type: sizes, colours and fonts in style runs, tracking, kerning (metrics / optical / off), manual leading, baseline shift, faux bold/italic, all caps, small caps (faux and OpenType), super/subscript, point alignment, paragraph alignment and all four justifications, hyphenation on/off, indents and space before/after, horizontal/vertical scale, underline/strikethrough, vertical Latin (rotated/upright) and CJK text, a vertical paragraph, five warps, text on a closed and an open path, OpenType ligatures (on/off), discretionary ligatures, fractions, old-style figures, ordinals, the five anti-alias modes, type with layer styles and with a blend mode |
| `adjustments/<mode><bits>/` | 135 | Adjustment layers in RGB 8/16/32, Grayscale 8/16/32, CMYK 8/16 and Lab 8/16: Levels, Curves (composite and per channel), Brightness/Contrast (modern and legacy), Exposure, Vibrance, Hue/Saturation (and Colorize), Color Balance, Black & White with tint, Photo Filter, Channel Mixer, Gradient Map, Selective Color, Invert, Posterize, Threshold, where Photoshop offers them in that mode and depth. Every directory has `baseline-layer-copy.psd` (no adjustment) to separate mode/depth decoding from adjustment maths. `rgb8/` also has a masked adjustment with opacity, a clipped adjustment with a blend mode and a stack |

File names describe the feature and its parameters (`bevel-inner-chisel-soft`, `sf-unsharp-mask-300-r5-t8`).
Adjustments Photoshop doesn't offer in a mode/depth (e.g. Vibrance in Grayscale, anything but
Levels/Curves/Exposure/... at 32 bits) are skipped by the generator rather than saved as no-ops.

## How the tests use it

- `cargo test -p photocraft-io --test corpus photoshop_oracle_corpus -- --nocapture`: imports every
  file, flattens it and compares with the merged composite (pass: within 2/255), and checks that
  our PSD export re-imports to the same rendering. Smart objects and type layers composite
  Photoshop's cached pixels here, so this measures import, effects, adjustments and compositing.
- `cargo test -p photocraft-engine --test photoshop_oracles -- --nocapture`: re-renders every smart
  object from its embedded source through our smart-filter stack and every type layer through our
  text engine, then compares with the merged composite. This is the smart-filter and text-engine
  failure map.

Both print a per-file table and per-feature totals and assert pass floors (raise them as fixes
land, never lower them). `PHOTOCRAFT_PS_CORPUS=<dir>` points both at another copy (e.g. a fresh
generator output).

## Regenerating

On a Mac with Photoshop installed: `tools/photoshop-oracles/generate.sh [filter-regex]`. It drives
the running (or launched) Photoshop through AppleScript `do javascript`; macOS asks once for
Automation permission (terminal → Adobe Photoshop). It opens one small document at a time, saves
it here and closes it, and restores the Units and Maximize Compatibility preferences it changes.
Output lines are `ok`, `skip` (not available in that mode/depth) or `FAIL`.

The output is reproducible in content but not byte-for-byte (Photoshop writes fresh document ids,
timestamps and XMP). Two details:

- **Add Noise** stores its random seed (`FlRs`) in the smart filter, so Photoshop re-renders it
  identically; we can only match it through the cached pixels, not by re-running the filter.
- **Fonts** (PostScript names): `ArialMT`, `Arial-BoldMT`, `TimesNewRomanPSMT`, `Georgia`,
  `Georgia-Italic`, `CourierNewPSMT` (shipped with macOS and Windows; metric-compatible Liberation
  fonts exist elsewhere), `SourceSerifRoman-Regular` (Source Serif, SIL OFL; Photoshop bundles it
  as a variable font, used for the OpenType features) and `HiraginoSans-W3` (macOS, CJK). The
  text-engine re-render needs the same fonts installed to be meaningful.

No ICC profiles are embedded (`embedColorProfile = false`): the files carry no vendor profiles,
and untagged data is read with the same defaults on both sides of the comparison. CMYK and Lab
files were converted from RGB with Photoshop's default colour settings at generation time; the
pixel values are just data.

## Provenance and licence

Authored by the PhotoCraft contributors with Photoshop from generated gradients, shapes and text
(no third-party images, no Photoshop presets, patterns, styles or contours: the contour curves and
gradients are our own point lists in the generator). Photoshop was used as a tool and its output
observed (clean-room); none of its code or assets are included. Licensed like the rest of the
project, MIT OR Apache-2.0, and redistributable as test data.
