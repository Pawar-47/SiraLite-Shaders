# SiraLite Shaders 1.2.0

Movement and shade. Everything added here is either free per pixel or paid for
per vertex, which is the only kind of feature this pack can afford.

## New

- **Waving grass, flowers, crops and leaves**, driven by block ids from
  `shaders/block.properties`. Vertex stage only: two sine calls per vertex and
  nothing per pixel.
- **Moving water surface** plus a **sun glint** at grazing angles.
- **Water-only surface treatment.** Glass, ice and stained glass no longer get
  the water sheen, because the pack now knows which block it is drawing.
- **Underwater caustics** while the camera is submerged, free above water.
- **Shadows tinted with sky light** instead of going black, so shade looks like
  shade.
- **Sunset and sunrise glow gathers on the sun's side** of the sky instead of
  ringing the whole horizon.
- **Dither before the 8-bit write**, so fog and sky gradients stop banding.

## Speed

- `POST_PROCESSING` can remove the whole post pass in one click.
- `shadowDistance` (96 blocks) with a fade-out, and no translucent geometry in
  the shadow pass at all.
- Ultra Performance stays the default: no shadow pass, one post pass, two
  texture fetches per terrain pixel.

## Install

1. Fabric Loader for Minecraft 1.21.5, plus Iris 1.8.x (Sodium recommended).
2. Drop `siralite-shaders-1.2.0-shaderpack.zip` into `shaderpacks/`. Do not
   unzip it.
3. Options > Video Settings > Shader Packs > SiraLite Shaders > Apply.

If you are short on frames, read the "Squeezing FPS on a real low-end PC"
section of the README before changing anything in the shader.

## Honest note

This release was written and packaged without a GPU or a Minecraft install. The
sources pass structural checks and CI builds the zip; nobody has yet seen it
running. No FPS numbers are given because none were measured. If the pack fails
to compile on your GPU, the `[Iris]` lines in the game log say where.
