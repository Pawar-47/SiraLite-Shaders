# SiraLite Shaders

A shader pack for **Minecraft Java Edition** that is built for old, weak
computers first and pretty pictures second - and tries hard to deliver both.

SiraLite is designed around one machine class: an older Intel Core i3, 8 GB of
RAM, and whatever integrated graphics came with that generation. On hardware
like that a conventional shader pack turns a playable game into a slideshow,
because those packs spend their budget on shadow cascades, screen-space
reflections, volumetric clouds and multi-pass bloom. SiraLite spends its budget
on the things that are cheap and visible: light colour, sky colour, water, fog,
and one careful colour grade.

Written from scratch for Iris, using `ascpixi/minecraft-shader-template` as the
project skeleton. See [CREDITS.md](CREDITS.md) for exactly what came from where.

## Status, honestly

| Question | Answer |
| --- | --- |
| Is this a real, complete shader pack? | Yes. Every program the pack ships is implemented; there are no stubs and no placeholder code. |
| Does it package into a valid shader zip? | Yes. CI runs the structural source checks and `gradlew assemble` on every push, publishes `siralite-shaders-1.4.0-shaderpack.zip` as a **GitHub release**, and attaches the same zip to the workflow run. Releases are additive: earlier versions stay published. See [Verification](#verification). |
| Has it been compiled and run in Minecraft? | **No.** It was written in an environment with no GPU and no Minecraft. Packaging is verified; GPU compilation and appearance are not. |
| Why is the release zip only about 24 KB? | Because the pack is pure GLSL - about 1,300 lines of source and not one image. See [Why the release is so small](#why-the-release-is-so-small). |
| Are there FPS numbers? | **No, and there will not be any invented ones.** Everything below labelled as an optimisation is a code-level property you can check by reading the file, not a measurement. |
| Is it tested on your Core i3? | Not yet. That test is the next step, and it is yours to run. Start with [Squeezing FPS](#squeezing-fps-on-a-real-low-end-pc). |

Treat this as a complete, reviewable first release that needs one round of
in-game testing, not as a pack with a benchmark history.

## Hardware target

- CPU: older Intel Core i3 (dual core, low clocks, weak memory subsystem).
- RAM: 8 GB, shared with the integrated GPU.
- GPU: older integrated or entry-level graphics with no dedicated VRAM of its
  own, so every texture fetch and every render target is paid for twice - once in
  bandwidth, once in the memory it steals.
- OS: Windows.
- Launcher: SK Launcher.
- Edition: Minecraft Java Edition.

Design consequences, in order of importance:

1. **Bandwidth beats ALU.** Reading one extra full-screen 8-bit target costs more
   than dozens of arithmetic instructions on this class of hardware. The pack
   therefore keeps one colour target and re-reads it at most twice.
2. **Fill rate is the wall.** Anything done per pixel is done 1920x1080 times a
   frame at 1080p. Per-pixel work is treated as expensive by default.
3. **Geometry passes are not free.** Re-rendering the world for shadows doubles
   vertex work and draw calls, and on these CPUs the driver overhead is real.
   Shadows are therefore off unless you ask for them.
4. **Integrated GPUs are usually old OpenGL.** Nothing newer than OpenGL 3.3 /
   GLSL 3.30 is used anywhere in the pack.

## Design philosophy

- **One shot, one pass.** Lighting happens once, in the forward pass, while the
  geometry is already in registers. Post processing is a single `composite` pass.
- **Keep vanilla's good decisions.** The vanilla lightmap already encodes smooth
  lighting, ambient occlusion, block versus sky light, and the dimension ambient
  light. SiraLite keeps that curve and only tints it, which is why caves stay
  dark, the End stays visible, and torches stay warm without any extra work.
- **Reuse what the game gives you free.** Sky colours come from vanilla's own
  `skyColor` and `fogColor`, so biome tint, rain, thunder and the day cycle work
  without a single line of simulation.
- **Fake it if the fake is indistinguishable.** Water "reflections" are an
  analytic sky gradient weighted by view angle. There is no reflection pass
  anywhere in the pack, and it costs no texture fetch.
- **Every expensive feature is opt-in, and off.** Shadows, soft shadows, bloom,
  ambient occlusion, vignette and water waves all start off in the default
  preset.
- **No effect exists to pad a feature list.** Volumetric clouds, screen-space
  reflections, TAA, parallax, path tracing and cascaded shadow maps are absent on
  purpose, and [Known limitations](#known-limitations) says so.

## Requirements

| Requirement | Version |
| --- | --- |
| Minecraft Java Edition | **1.21.5** - the only version this pack is written against |
| Iris | 1.8.x for 1.21.5 (the build pins `1.8.11+1.21.5-fabric`) |
| Loader | Fabric Loader 0.16.x (pinned `0.16.14`) |
| Optional | Sodium 0.6.x for 1.21.5 (pinned `mc1.21.5-0.6.12-fabric`) |
| Graphics API | OpenGL 3.3 / GLSL 3.30 or newer |
| Java (for the dev client only) | 21 |

Other Minecraft versions are **not** supported and not claimed to work. Vanilla
1.21.5 shader programs, block IDs and the lightmap behaviour change between
versions, so a 1.21.4 or 1.22 install is untested territory.

### About old GPUs

The shaders are GLSL 3.30 (`#version 330 compatibility`), which is what Iris
needs and the oldest profile the pack targets. That means:

- Intel HD 4000 (Ivy Bridge) and newer expose OpenGL 4.0 or better on current
  Windows drivers and meet the bar in principle.
- Intel HD 3000 (Sandy Bridge) and older expose OpenGL 3.1 or partial 3.3
  depending on driver and OS. **Check what your driver reports before expecting
  anything.** This pack has not been verified on any specific GPU.
- Iris itself has requirements of its own that no shader pack can lift.

Useful reference: if plain Iris with no shader pack does not work on the machine,
no shader pack will.

## Installation

### With SK Launcher

1. Install **Fabric** for Minecraft **1.21.5** from SK Launcher's version manager.
2. Put **Iris** (and **Sodium**, recommended) into the profile's `mods` folder.
   Get them from Modrinth; match the 1.21.5 versions above.
3. Start the game once, then close it. This creates the game directory.
4. Copy `siralite-shaders-<version>-shaderpack.zip` into
   `<game directory>/shaderpacks/`. In SK Launcher the game directory is shown in
   the profile settings; by default it is `%APPDATA%\.minecraft`.
5. Start the game, then **Options > Video Settings > Shader Packs**, select
   **SiraLite Shaders** and press **Apply**.
6. Open **Shader Pack Settings** to choose a preset.

Do not unzip the file. Iris loads the zip directly.

### Downloads

Every push to `master` builds the pack and publishes it as a GitHub release.
Open **Releases** on this repository and download
`siralite-shaders-<version>-shaderpack.zip`; the same zip is attached to the
workflow run as an artifact.

### From source

```
gradlew assemble
```

The pack is written to `build/releases/siralite-shaders-<version>-shaderpack.zip`.
Copy that zip into `shaderpacks/` exactly as above.

## Presets

Three profiles ship with the pack, selectable with the profile button in
**Shader Pack Settings**. The default values in the shader source are exactly the
first preset, so a fresh install is already on **Ultra Performance**.

### Preset 1 - Ultra Performance (default)

Maximum FPS. No shadow pass at all, no extra fetches, no extra passes.

| | |
| --- | --- |
| Shadows | Off. The shadow pass is not even rendered. |
| Post processing | One pass: one scene fetch, one depth fetch. Switch `POST_PROCESSING` off to remove that pass entirely. |
| Water | Tinted lighting plus a cheap analytic sky reflection at 15%, and a sun glint. No shimmer. |
| Vegetation | Grass, leaves and the water surface sway; grass and leaves get richer colour. Vertex cost only, so it stays on. |
| Clouds and sky | Vanilla cloud shapes, graded by time of day, plus high cirrus and a warm sun glare. |
| Sky / fog / grade | On - these are arithmetic only and are the pack's look. |
| Pixel cost on terrain | 1 texture fetch, 1 lightmap fetch, arithmetic |

### Preset 2 - Balanced

The intended everyday setting if the machine can afford it.

| | |
| --- | --- |
| Shadows | On, hard shadows, one tap, 1024x1024 map, 96-block distance. |
| Water | Waves on, reflection at 35%. |
| Grade | Slightly more saturation and warmth. |
| Vignette | On. |
| Added pixel cost | One shadow map fetch where sky light reaches, plus 4 sin/cos on water |

### Preset 3 - Visual Performance

The best this pack gets without leaving the low-end budget.

| | |
| --- | --- |
| Shadows | On, 4-tap PCF, still a 1024x1024 map. |
| Water | Waves on, reflection at 50%. |
| Bloom | On (four wide taps of the scene buffer). |
| Vignette | On. |
| Grade | Higher saturation, contrast and sunset warmth. |

Ambient occlusion is available in all presets but **off in all of them** by
default; it can be switched on in **Post Processing**.

## Configuration

All options live in `shaders/lib/settings.glsl` and are shown in **Shader Pack
Settings** with a label and tooltip from `shaders/lang/en_us.lang`.

| Option | Default | What it does |
| --- | --- | --- |
| `POST_PROCESSING` | on | The whole post pass: fog, grade, underwater tint. Off removes an entire full-screen pass |
| `SHADOW_QUALITY` | `0` | 0 = off (no shadow pass at all), 1 = hard shadows (one tap), 2 = soft shadows (4 taps) |
| `shadowMapResolution` | `1024` | 512, 1024 or 2048. Iris constant; lower is faster and blurrier |
| `shadowDistance` | `96` | Blocks the shadow pass covers. Lower re-renders much less geometry |
| `shadowIntervalSize` | `7.0` | Softens the banding a low resolution shadow map shows on long shadows |
| `entityShadowDistanceMul` | `0.25` | How far away entities still cast shadows, as a fraction of the shadow distance |
| `SHADOW_STRENGTH` | `0.75` | How much direct light the shadows remove |
| `EXPOSURE` | `1.0` | Overall brightness multiplier, after lighting |
| `SATURATION` | `1.08` | Colour saturation around each pixel's brightness |
| `CONTRAST` | `1.05` | Contrast around mid grey |
| `SUNSET_STRENGTH` | `1.0` | Warmth of sunrise and sunset in sky, fog and light tint |
| `NIGHT_BRIGHTNESS` | `1.0` | Light level after dark |
| `FOG_DENSITY` | `1.0` | How close the distance fog starts |
| `CLOUD_SHADING` | on | Grade vanilla's cloud shapes by time of day and sunset warmth |
| `SKY_CIRRUS` | on | Thin high cloud streaks over the sky (sky pixels only) |
| `SUN_GLARE` | on | Warm glare around the sun, strongest when it is low |
| `WAVING_PLANTS` | on | Grass, flowers, crops and leaves sway in the wind (vertex stage only) |
| `WAVING_WATER` | on | The water surface moves up and down (vertex stage only) |
| `WAVE_STRENGTH` | `1.0` | How far vegetation and water travel. Does not change the cost |
| `VEGETATION_POLISH` | on | Richer colour and a little extra light on grass and leaves |
| `WATER_REFLECTIONS` | on | Analytic sky reflection on water |
| `WATER_REFLECTION_STRENGTH` | `0.15` | How much sky is mixed into the water surface |
| `WATER_WAVES` | off | Animated shimmer of the reflected direction |
| `WATER_DEPTH` | on | Water colour and opacity follow its depth, plus a shoreline rim |
| `UNDERWATER_CAUSTICS` | on | Light ripples on everything while submerged |
| `HANDHELD_LIGHT` | on | A torch or lantern in your hand lights the ground around you |
| `DIMENSION_TUNING` | on | Warm light and thick haze in the Nether, cool and clear in the End |
| `BLOOM` | off | Cheap four-tap bright pass |
| `VIGNETTE` | off | Darkened screen corners |
| `SSAO` | off | Depth-only contact shadows |

`shaders.properties` also turns off vanilla's underwater overlay and vanilla's
vignette overlay, because the pack draws its own version of both, and it stops
translucent geometry (water, glass, ice) from being drawn into the shadow map.

Note that turning `POST_PROCESSING` off also removes the underwater tint, since
that tint is drawn in the post pass.

## Squeezing FPS on a real low-end PC

On an old Core i3 with integrated graphics, the shader pack is usually not the
biggest cost - the render distance, the simulation distance and the number of
chunks the CPU has to build are. These levers will move your framerate further
than any line of GLSL, and none of them need a better GPU.

1. Load **Ultra Performance**. If you are still under ~40 FPS, turn
   `POST_PROCESSING` off: that removes a full-screen pass outright.
2. **Render distance 6-8 chunks.** Every chunk is geometry the CPU builds and the
   GPU rasterises. This is the single biggest lever on this hardware.
3. **Simulation distance 5.** Mobs and random ticks are CPU work, and the i3 is
   where you are bottlenecked.
4. **Graphics: Fast.** Clouds off (or Fast), particles Minimal, entity shadows
   off, view bobbing off, mipmap level 2-4.
5. **Smooth lighting: ON.** It is baked into the vertex data, it costs almost
   nothing, and it is what the pack's tinted lightmap is built on. Turning it off
   makes the world look flat without gaining much.
6. **Sodium settings:** chunk builder threads 2, leave render distance culling on.
7. **Allocate 2-3 GB of RAM**, not more. With 8 GB total, Windows and the game
   share it; over-allocating causes swapping, which is far worse than a small heap.
8. **Use a 64-bit Java 21 runtime.**
9. **Vsync off, fullscreen at native resolution** (a scaled window costs an extra
   copy per frame), Windows power plan on "High performance", and close the
   browser - on 8 GB that alone is often 10-20% of your frame time.

Only the first item is specific to this pack. The rest is standard Minecraft
configuration, and none of it is measured on your machine - it is the set of
levers that matter, not a benchmark.

## Why the release is so small

The packaged zip is about 24 KB. That is not a missing feature; it is what this
much shader code weighs.

- The pack is about 1,300 lines of GLSL across 18 program pairs and 4 libraries,
  with no textures, no noise images, no skybox art and no cloud sprites.
- Text compresses extremely well, so a couple of thousand lines become about
  24 KB in a zip.
- Shader packs that ship 1-10 MB are almost always carrying images. Those images
  cost VRAM and texture bandwidth on an integrated GPU, which is exactly the
  resource this pack is trying to protect. A missing texture is a feature here.
- For comparison, the whole `colortex` budget of this pack is one 8-bit colour
  target. There is nothing else to ship.

## What this pack learned from

The reference library for shader packs is [Modrinth](https://modrinth.com/shaders).
The design decisions in this pack were checked against openly licensed packs
published there - **Miniature Shader** (MIT), **MakeUp - Ultra Fast**
(LGPL-3.0) and **Mellow** (MIT) - and [docs/RESEARCH.md](docs/RESEARCH.md)
records exactly what was read, what was adopted, what was rejected and why.

Two things worth stating plainly:

- **No third party shader code, and no third party pack zip, is in this
  repository.** Several of the most downloaded packs on Modrinth are
  All-Rights-Reserved; committing one here "for reference" would breach its
  licence. Reference material stays outside the repository and the techniques
  were rewritten in this project's own code.
- **The expensive features those packs are known for were rejected on purpose**,
  not forgotten: screen-space reflections, multiple G-buffer targets, TAA,
  volumetric clouds, depth of field, motion blur. Each of them costs more per
  frame than this pack's entire budget on an older i3 with integrated graphics.

## Performance: what was actually optimised

Every item below is a property of the code in this repository. None of it is a
measured FPS claim.

**Fewer passes and fewer targets**

- One colour render target (`colortex0`) and nothing else. No normals target, no
  specular target, no separate depth or history buffer. This is the largest single
  bandwidth saving available to a shader pack.
- The template's `deferred` pass was **deleted**. It only copied `colortex0` into
  itself, and it was a full-screen read plus a full-screen write, every frame.
- All post processing happens in the single `composite` pass: one scene fetch, one
  depth fetch, then arithmetic.
- `composite` can be switched off completely with `POST_PROCESSING`, so the very
  weakest machine can shed the last full-screen pass and still keep the improved
  terrain, sky and water.
- No `final` pass, no `composite1..15`.
- The shadow pass renders no translucent geometry, so water, glass and ice never
  cost shadow-pass fill rate, and `shadowDistance` (96 blocks by default) keeps
  the re-rendered geometry short.

**Fewer texture fetches**

- Terrain, the majority of pixels, costs exactly two fetches: `gtexture` and
  `lightmap`.
- The vignette, saturation, contrast, exposure, white balance, sky gradient, fog
  and underwater tint all cost **zero** extra fetches.
- Water reflection costs zero fetches: it is an analytic sky colour, not a
  texture.
- The optional effects each add their own fetches and are all off by default:
  bloom adds 4, SSAO adds 4, shadows add 1 per lit pixel.

**Cheaper arithmetic**

- No `pow`, `exp`, `log` or `noise` in any default path. Fresnel uses `(1-cos)^4`
  as two multiplies; the sun glow uses `cos^8` as three multiplies; the sky
  gradient uses `sqrt` where most packs would use `pow`.
- No loops anywhere in the pack.
- No per-pixel branching on the default preset. Optional code is removed by the
  preprocessor, not skipped at runtime.
- The colour grade works in the buffer's own gamma space, which avoids three
  `pow()` calls per pixel that a linear-space grade would need.
- The lightmap tint uses a convex blend with no division, so there is no
  division by zero and no NaN in unlit or ambient-only areas.

**Cheaper vertex work**

- `gl_Position` is built from the view-space position the vertex shader already
  needed, instead of calling `ftransform()` and multiplying the matrices twice.
- The face normal is normalised once per vertex, not per pixel. There is a guard
  so a missing normal becomes a zero vector and a neutral result rather than a
  NaN.
- Varyings are limited to what is actually used: `texcoord`, `lmcoord`, `glcolor`,
  `viewPos`, `normalView`, plus one float on the water program for the water mask.
- Vegetation and water motion are per vertex, never per pixel: two sine calls on
  grass and leaves, one on water, and nothing at all for blocks without an id.

**Cheaper shadows**

- Off by default, and when off the shadow sampler is not declared at all, so Iris
  detects that no program uses a shadow buffer and skips the shadow pass
  entirely - not just the lookups.
- `shadowtex1` (opaque geometry only) is sampled instead of `shadowtex0`, so water
  and glass never cast solid shadows.
- One tap by default when enabled; four taps only for "soft".
- A constant depth bias, and a frustum test that returns "lit" instead of
  sampling garbage.
- Shadows are scaled by the pixel's sky light, so caves and interiors do not pay
  for a lookup that would change nothing - and do not darken incorrectly.

**Cheaper water**

- No reflection, refraction or screen-space pass. One extra branch-free block of
  arithmetic in the water shader only.
- The water depth effect is one fetch of Iris's pre-translucents depth copy, on
  water pixels only, and it replaces work that would otherwise be spent guessing.
- Waves use two sines per axis, only when enabled.

## File map

```
shaders/
  lib/settings.glsl     every user option; included everywhere
  lib/common.glsl       shared uniforms, sun elevation, sky gradient, colour grade,
                        depth linearisation
  lib/lighting.glsl     the lightmap tint, sun facing, shadeLit() used by all lit programs
  lib/shadow.glsl       shadow map lookup; only compiled when SHADOW_QUALITY > 0
  lib/waving.glsl       per-vertex sway for vegetation and the water surface
  block.properties      block ids handed to the shaders as mc_Entity.x
  shadow.vsh/.fsh       shadow pass; fsh only discards cutouts and writes depth
  gbuffers_terrain      blocks and chunk geometry (the hot path)
  gbuffers_water        translucent terrain: water, ice, glass
  gbuffers_block        block entities (chests, signs, beds)
  gbuffers_entities     mobs, items, players
  gbuffers_hand         held item; gbuffers_hand_water its translucent parts
  gbuffers_textured     textured geometry; gbuffers_textured_lit the lit variant
  gbuffers_basic        untextured geometry: outlines, leashes
  gbuffers_armor_glint  enchantment glint (tinted lightmap, no shadows)
  gbuffers_beaconbeam   emissive, no lighting
  gbuffers_spidereyes    emissive, no lighting
  gbuffers_clouds       vanilla clouds, unchanged
  gbuffers_skybasic     the analytic sky gradient and stars
  gbuffers_skytextured  sun and moon quads
  gbuffers_weather      rain and snow
  composite.vsh/.fsh    the one and only post processing pass
  shaders.properties    screens, sliders and the three profiles
  lang/en_us.lang       option labels and tooltips
pack.mcmeta             pack metadata (required at the zip root)
tools/check_shaders.sh  structural source checks, no GPU needed
.github/workflows/      CI: source checks plus `gradlew assemble`
```

There is deliberately **no** `deferred.*`: its absence removes a full-screen copy.

## Known limitations

- **Not tested in game.** See [Status](#status-honestly). The first thing to do
  with this pack is load it on the target machine and look at it.
- **Shadows are a single non-cascaded map.** At 96 blocks and 1024x1024 the
  shadows are soft-ish and lose precision far away. Cascades were rejected
  because they multiply the geometry passes.
- **Water reflections are sky-only.** They ignore terrain, entities and the sun
  disc except as colour. That is the trade that makes them free.
- **Waving needs `block.properties`.** If that file is not loaded, or a block name
  in it does not exist in your Minecraft version, that block simply does not
  move. Nothing breaks; the motion is skipped.
- **Tall plants sway from their own block's base.** A two block tall plant has two
  halves that each sway from their own bottom edge, so at very high
  `WAVE_STRENGTH` a slight seam can appear between the halves.
- **No parallax, no TAA, no SSR, no volumetric clouds.** All of them cost more
  than the pack's total budget.
- **No bloom quality to speak of.** The optional bloom is four wide taps, not a
  multi-pass blur. It is a glow, not a photographic bloom.
- **Ambient occlusion is depth-only.** It is a four-tap contact shadow with no
  normal-aware half-sphere sampling, so it darkens grooves and not much else. It
  is off by default and cannot be verified from here.
- **Clouds keep vanilla's shapes.** The pack grades their colour and adds cirrus
  above them; it does not generate volumetric clouds, so the blocky silhouettes
  are vanilla's. Volumetric clouds cost more per frame than this pack's entire
  budget, and every attempt to fake them cheaply looks worse than vanilla.
- **Nights are dark.** `NIGHT_BRIGHTNESS` exists because the pack follows
  vanilla's lightmap; raise it if the game is unplayable for you.
- **The `pack_format` in `pack.mcmeta` is cosmetic.** Iris reads the zip, not the
  metadata version.

## Development

Requirements: JDK 21 and a GPU that Minecraft can run on. Windows or Linux.

```
gradlew runShaderClient     # dev client, Iris enabled, pack applied automatically
gradlew assemble            # build the release zip
```

`runShaderClient` copies the pack into `run/shaderpacks/siralite-shaders-dev/`,
symlinks or junction-links `shaders/` back to the repository so shader edits are
live, writes an `iris.properties` that selects the pack, and starts the client.
Press `R` in game (with the pack selected) to reload shaders after an edit.

`assemble` produces `build/releases/siralite-shaders-<version>-shaderpack.zip`
containing `shaders/`, `pack.mcmeta` and the licence.

### Editing rules

See [AGENTS.md](AGENTS.md) for the architecture and performance rules this
codebase is held to. The short version: one colour target, one post pass, options
only in `lib/settings.glsl`, and do not add a per-pixel cost without an option.

### Verification

CI (`.github/workflows/build.yml`) runs on every push:

1. `bash tools/check_shaders.sh` - structural source checks: `#version` present,
   balanced braces and parentheses, `RENDERTARGETS` present, every fragment
   shader input matched by a vertex shader output, every `#include` resolvable,
   no option defined twice with different values.
2. `./gradlew assemble`, then the zip is uploaded as an artifact and published as
   a GitHub release tagged `v<version>`. Both steps fail the build if no zip is
   produced.

The 1.0.0 run produced `siralite-shaders-1.0.0-shaderpack.zip` at 24,271 bytes,
which GitHub wrapped in a 16,452-byte artifact download. That proves the sources
are structurally sound and that the pack packages correctly - you can download the
release zip from the Releases page instead of building it yourself. It does **not**
prove the shaders compile on a GPU or that they look right; only a real client can.
Check the console for `[Iris]` compile errors after applying the pack.

## Credits and licence

- Project skeleton, build configuration and program layout started from
  [`ascpixi/minecraft-shader-template`](https://github.com/ascpixi/minecraft-shader-template)
  (itself based on ShaderLABS Base-330). That repository shipped no licence file
  at the time of cloning; what was and was not taken from it is spelled out in
  [CREDITS.md](CREDITS.md).
- All shader code in this pack was written for SiraLite Shaders.
- Licensed under the MIT licence, see [LICENSE](LICENSE).
