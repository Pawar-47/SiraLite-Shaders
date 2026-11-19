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
weak hardware, plus two profiles for the same purpose. Nothing was stubbed,
deleted or rewritten:

- The shader logic is upstream's, unchanged.
- What changed is `shaders/lib/config.glsl` (default values) and
  `shaders/shaders.properties` (two profiles, and two passes made conditional).
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

Two profiles are added above MakeUp's own ladder:

- **`MAX_FPS`** - restores the configuration above in one click.
- **`MAX_FPS_NOFOG`** - the same, plus distance fog off. That removes one
  full-screen texture fetch from every block pixel, the last real per-pixel saving
  in the pack. It costs the haze that hides the edge of your render distance, so
  compare before choosing.

MakeUp's original profiles (Potato through Extreme) are untouched and still
available.

## Install

### With SK Launcher

1. Install **Fabric** for Minecraft **1.21.5** from the launcher's version manager.
2. Put **Iris** (and **Sodium**) into that profile's `mods` folder, matching 1.21.5.
3. Start the game once, then close it.
4. Copy `siralite-shaders-2.0.0-shaderpack.zip` into `<game directory>/shaderpacks/`.
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
