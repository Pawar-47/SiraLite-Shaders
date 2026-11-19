# SiraLite Shaders 2.0.0

The project now ships **MakeUp - Ultra Fast v9.6**, ported in completely and
tuned for a Core i3 with integrated graphics. The previous independently written
pack (SiraLite 1.x) is kept in `legacy/siralite-shaders/` and its builds remain on
the releases page.

## What changed

- **Complete port.** `shaders/` is MakeUp's full tree: every program, every
  per-dimension folder, both texture sets, the volumetric clouds, the reflection
  code, the works. Nothing was stubbed or removed.
- **Tuned defaults.** Shadows, volumetric clouds and their reflections, raymarched
  reflections, TAA, bloom, ambient occlusion, godrays, material gloss, refraction
  and sun reflection are off by default; the sampling counts for what remains are
  at their cheapest values. `Ref/OPTIMIZED.md` lists every value.
- **Two profiles added** on top of MakeUp's own ladder: `MAX_FPS` (the default
  state) and `MAX_FPS_NOFOG` (also drops the distance fog, which removes one
  full-screen fetch per block pixel at the cost of chunks popping).
- **Two passes skipped** when nothing in them can run: `composite1` (bloom and
  depth of field only) and `composite2` (antialiasing and motion blur only).

## Licence

`shaders/` is **LGPL-3.0-or-later**, because it is a modified version of MakeUp.
The licence text ships with the pack (`LICENSE-LGPL-3.0.txt`), and
[NOTICE.md](../NOTICE.md) lists the changes and their date as the LGPL requires.
Everything else in the repository - the build, the checks, the docs, and the
previous 1.x pack - remains MIT.

If you were using SiraLite 1.x under MIT and do not want an LGPL pack, the old
sources are in `legacy/siralite-shaders/` and the v1.x releases are untouched.

## Install

1. Fabric Loader for Minecraft 1.21.5, plus Iris 1.8.x (Sodium recommended).
2. Drop `siralite-shaders-2.0.0-shaderpack.zip` into `shaderpacks/`. Do not
   unzip it.
3. Options > Video Settings > Shader Packs > apply the pack, then open its
   settings and confirm the profile is **MAX_FPS**.

## Honest note

The tuning is grounded in reading the code, not in measurement: nobody has run
this on a GPU here, and no framerate numbers are claimed. If something looks
wrong, every change is a single value in `shaders/lib/config.glsl`, and the
unmodified original is in `Ref/` to diff against.
