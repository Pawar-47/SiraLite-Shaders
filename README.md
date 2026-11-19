# SiraLite Shaders

A shader pack for **Minecraft Java Edition**, shipped from this repository as a
**modified version of MakeUp - Ultra Fast v9.6**, tuned for an older Intel Core i3
with integrated graphics and 12 GB of RAM.

## Licensing, read this first

This repository holds two things under two licences:

- **`shaders/` - the pack that is built and released - is LGPL-3.0-or-later.** It
  is a modified version of MakeUp - Ultra Fast by Javier Garduño (KDXavier). The
  licence text ships inside the pack as `LICENSE-LGPL-3.0.txt`.
- **Everything else is MIT**: the build files, the check script, the docs, the
  release workflow, and the previous SiraLite 1.x pack in `legacy/`.

[NOTICE.md](NOTICE.md) lists every change made to the upstream pack, with its
date, as the LGPL requires. [CREDITS.md](CREDITS.md) says who made what.

## What this is

MakeUp's complete pack - every program, every per-dimension folder, its clouds,
water, reflections, TAA, glow and texture sets - with its defaults retuned for
weak hardware, plus three profiles for the same purpose. Nothing was stubbed,
deleted or rewritten:

- The shader logic is upstream's, unchanged.
- What changed is `shaders/lib/config.glsl` (default values) and
  `shaders/shaders.properties` (three profiles, and two passes made conditional).
- The unmodified original sits in `Ref/` so you can diff against it, and
  [Ref/OPTIMIZED.md](Ref/OPTIMIZED.md) records why each value was chosen.

## Hardware target

- Older Intel Core i3, 12 GB of RAM, integrated graphics, Windows.
- Integrates with Iris; Sodium recommended.
- Not a pack for strong GPUs. On a fast machine, use MakeUp itself with its own
  higher profiles.

## Defaults and profiles

The shipped defaults are the cheapest configuration of the pack:

| Off by default | Because |
| --- | --- |
| Shadows | A whole second scene render |
| Volumetric clouds, cloud reflections, End clouds | A raymarch per pixel, plus a second cloud render |
| Raymarched water reflections, refraction, sun glint | Screen-space raymarching |
| TAA / FXAA | A history buffer and a full-screen resolve |
| Bloom, godrays, depth of field, motion blur | Extra passes |
| Ambient occlusion, material gloss | Extra taps and per-pixel work |

With those gone the pack still has its sky, its grade, its water shape, its fog
and its waving foliage, and runs as four full-screen passes.

Three profiles are added above MakeUp's own ladder:

- **`MAX_FPS`** - restores the configuration above in one click.
- **`MAX_FPS_NOFOG`** - the same, plus distance fog off. That removes one
  full-screen texture fetch from every block pixel, the last real per-pixel saving
  in the pack. It costs the haze that hides the edge of your render distance, so
  compare before choosing.
- **`BSL_INSPIRED`** - the other end of the range: shadows at 840² over 105
  blocks, coloured shadows, volumetric clouds reflected in water and drawn in the
  End, volumetric light, bloom, TAA, AO at 5 samples, water refraction and sun
  glint, flipped-image water reflection, and a warm grade. It is the full
  BSL-style look in one click, tuned to survive on a mid-range GPU - reflection
  raymarching is deliberately left off. On integrated graphics expect a real
  framerate drop; that is what the default profile is for.

MakeUp's own profiles are untouched and still available from the profile menu:
*No effects*, *Shadowless Low / Medium / High*, *Low*, *Medium*, *High* and
*High (DoF)*.

## Climbing toward BSL-level graphics

The default is a floor, not a ceiling. Every effect BSL is known for is present in
this pack - it is MakeUp's tree, nothing was removed - and each one can be switched
back on from the pack's settings. Below is the order to do it in, cheapest first,
so your i3 keeps up as long as possible.

| Step | Switch on | Where | What it buys | What it costs |
| --- | --- | --- | --- | --- |
| 1 | `AO`, `AOSTEPS` 3 | Advanced options > Ambient occlusion | Contact shadow in corners and under overhangs; the cheapest thing that reads as depth | 3 depth taps per pixel (the slider goes 2-11) |
| 2 | `V_CLOUDS` 1 (static), `CLOUD_STEPS_AVG` 7 | Advanced options > Sun & clouds | Real layered volumetric clouds instead of vanilla billboards - the single biggest visual jump in the pack | A raymarch per sky pixel, 7 steps. Setting 2 lets the clouds change shape and costs more |
| 3 | `REFLECTION_SLIDER` 1 in Light, `SUN_REFLECTION` in Sun & clouds | Advanced options | Water mirrors the sky and the sun glints on it | A flipped copy of the frame, one fetch per water pixel. Setting 2 is true screen-space raymarching and costs much more |
| 4 | `AA_TYPE` 2 | Advanced options > Post effects | Smooths foliage edges and the volumetric clouds; the thing most people mean by "looks clean" | History buffer plus a full-screen resolve |
| 5 | `SHADOW_CASTING`, `SHADOW_QTY_SLIDER` 1, `SHADOW_DISTANCE_SLIDER` 0, `COLORED_SHADOW` off | Advanced options > Shadows | Sun shadows, and light shafts become possible | A second scene render - 300² of shadow map at 75 blocks with these two sliders, which is the cheapest it goes |
| 6 | `VOL_LIGHT` in Light, `BLOOM` in Post effects | Advanced options | Visible sun beams through foliage, and glow on lights | Full-screen passes at the end of the frame |

How to use it: turn on **one** step, play for a few minutes in the scene you care
about, and keep it only if the framerate stays where you want it. Do not enable two
at once; on an integrated GPU you will not know which one took your frames.

Three shortcuts if you would rather not go switch by switch:

- **`shadowless_medium`** is about steps 1-3 in one click - the best-looking
  configuration that does not pay for a shadow pass.
- **`medium`** is about steps 1-5: the full BSL-style look, shadow pass included.
- **`high`** is everything in that table, plus coloured shadows, cloud reflections
  and gloss - at MakeUp's maximum shadow resolution and distance.
- **`BSL_INSPIRED`** is the same full look tuned to survive on weaker hardware:
  the effects above at 840² of shadow map over 105 blocks, with a warm grade.

If you try only one thing, make it step 2. Clouds and sky are what the eye reads as
"a shader is running", and they cost less than shadows.

## Install

### With SK Launcher

1. Install **Fabric** for Minecraft **1.21.5** from the launcher's version manager.
2. Put **Iris** (and **Sodium**) into that profile's `mods` folder, matching 1.21.5.
3. Start the game once, then close it.
4. Copy `siralite-shaders-2.1.0-shaderpack.zip` into `<game directory>/shaderpacks/`.
   Do not unzip it.
5. Start the game, then **Options > Video Settings > Shader Packs**, select the
   pack and apply it. Open its settings and check the profile reads **MAX_FPS**.

### From source

```
gradlew assemble
```

The zip is written to `build/releases/`. Every push to `master` also publishes it
as a GitHub release, with the same zip attached to the workflow run.

## Running it on weak hardware

Reading the code only gets a pack so far; on an i3 the frame time is usually
spent outside the shader. In order of effect:

1. **Resolution.** An integrated GPU is fill-rate bound: 1080p → 1600x900 is about
   30% fewer pixels, → 1280x720 about 55% fewer.
2. **Render distance 8, simulation distance 5.** Chunk work is CPU.
3. **Allocate 4 GB, not more.** With 12 GB, leave the rest to the iGPU's shared
   memory, which is where this pack spends its bandwidth.
4. Then the switches above, cheapest first.

The reasoning behind every value, and what was checked in the pack's code before
stopping, is in [docs/MAKEUP-TUNING.md](docs/MAKEUP-TUNING.md).

## Development

Requires JDK 21 and a GPU Minecraft can run on.

```
gradlew runShaderClient     # dev client, Iris enabled, pack applied automatically
gradlew assemble            # build the release zip
```

`runShaderClient` stages the pack into `run/shaderpacks/`, links `shaders/` back to
the repository for live edits, writes an `iris.properties` that selects the pack,
and starts the client. Press `R` in game after an edit to reload shaders.

## Verification

CI (`.github/workflows/build.yml`) runs `tools/check_shaders.sh` and
`gradlew assemble` on every push, then publishes the zip as a release. The script
checks that every entry point declares a `#version` and includes its body, that
preprocessor conditionals balance in all 250-odd source files, and that every
`#include` resolves.

That proves the sources are structurally consistent and that the pack packages
correctly. It does **not** prove the shaders compile on a GPU, or that they look
right or run fast. Nothing in this repository has been measured on hardware, and
no framerate numbers are claimed anywhere.

## Known limitations

- **Tuned by reading, not by measuring.** Every value here is defensible from the
  code, none of it was benchmarked on the target machine.
- **The pack is somebody else's design.** Upstream's pass structure and its four
  full-screen passes are kept; the reductions are in configuration, plus two
  passes made conditional.
- **It is LGPL.** If you need MIT-only sources, use `legacy/siralite-shaders/`.
- **Minecraft 1.21.5 and Iris 1.8.x** are what this is built against. MakeUp
  supports much more, but this repository does not test any other version.

## Previous pack

SiraLite Shaders 1.x was an independent, MIT-licensed pack written for this
repository. It is preserved in [`legacy/siralite-shaders/`](legacy/siralite-shaders/)
and its builds remain published as v1.2.0 through v1.7.1. The research behind it,
including studies of Complementary Unbound and MakeUp, is in
[docs/RESEARCH.md](docs/RESEARCH.md).
