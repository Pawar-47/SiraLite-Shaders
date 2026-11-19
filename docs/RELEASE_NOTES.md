# SiraLite Shaders 1.3.0

Sky, water and plants, which is where a low-end pack can still look expensive.
Everything here is either a handful of arithmetic on pixels that were already
being shaded, or one depth fetch.

## Clouds and sky

- **Cloud shading.** Vanilla keeps its cloud shapes; the pack grades their
  colour. White by day, blue-grey at night, and warm from underneath at sunrise
  and sunset, where vanilla leaves them the same pale beige all day.
- **High cirrus.** Thin streaks of high cloud in the sky, projected so they slide
  past as you move and lit warm at dawn and dusk. Four sine calls, no texture.
- **Sun glare.** A warm halo around the sun's screen position, strongest when the
  sun is low, drawn only over clean sky so it never haloes a mountain.

## Water

- **Depth-based colour and transparency.** Water now reads Iris's
  pre-translucents depth copy: shallow water stays clear and bright, deep water
  turns blue and hides what is under it. One fetch, water pixels only.
- **Shoreline rim** on the last half block of shallow water.
- Reflections, the sun glint, the moving surface and underwater caustics are all
  still there.

## Plants

- **Waving** grass, flowers, crops and leaves (from 1.2.0), and now
- **Vegetation polish**: grass and leaves get richer colour and a little extra
  light, as if sunlight were passing through them. Branchless, and it only shows
  on vegetation.

## Still cheap

- Ultra Performance is the default: no shadow pass, one post pass, two texture
  fetches per terrain pixel.
- New per-pixel work is confined to the pixels it affects: sky, cloud and water
  pixels. Terrain, the hot path, gains one varying and a dozen instructions.
- Every new effect has an option and can be switched off one at a time.

## Install

1. Fabric Loader for Minecraft 1.21.5, plus Iris 1.8.x (Sodium recommended).
2. Drop `siralite-shaders-1.3.0-shaderpack.zip` into `shaderpacks/`. Do not
   unzip it.
3. Options > Video Settings > Shader Packs > SiraLite Shaders > Apply.

If you are short on frames, read "Squeezing FPS on a real low-end PC" in the
README before changing anything in the shader.

## Honest note

Written and packaged without a GPU or a Minecraft install. The sources pass
structural checks and CI builds and publishes this zip; nobody has yet seen the
result on a screen. No FPS figures are given because none were measured. If a
shader fails to compile on your GPU, the `[Iris]` lines in the game log name the
file and the line.
