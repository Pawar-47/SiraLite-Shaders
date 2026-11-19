# SiraLite Shaders 1.6.0

Complementary Unbound was downloaded from Modrinth and opened, file by file, and
two of its techniques were worth taking. The working notes are in
`docs/RESEARCH.md`.

## New

- **Potato profile.** A fourth profile for the weakest machines, built the way
  Complementary builds its own Potato: no post pass, no shadow pass, no
  reflections, no motion. What is left - terrain lighting, sky and shaded clouds -
  still looks better than vanilla and costs almost nothing.
- **Clouds read as thick.** Vanilla clouds are flat slabs at y=192, so the pack
  now shades each fragment by where it sits inside that slab: the top catches the
  sky, the base sits in shadow. Eight instructions, no volumetric work.
- **Clouds fade with distance**, so the layer stops softly instead of ending in a
  hard line at the edge of its radius.

## Unchanged guarantees

- Ultra Performance stays the default.
- Every effect has an option, and every profile is one click.
- Releases are additive: this release is new, and v1.5.0, v1.4.0, v1.3.0 and
  v1.2.0 stay published with their downloads untouched.

## Not taken from Complementary, and why

- Its ten or so composite passes, its nine per-dimension folder sets and its
  image assets: that is the cost structure of a pack built for stronger hardware.
- `oldLighting=false` with `separateAo=true`: the cleaner lighting model, but it
  requires rewriting the discard test in ten programs to read texture alpha
  instead of vertex alpha, with no way to look at the result here. Recorded as a
  deferral, not an oversight.
