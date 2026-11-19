# Optimized for max FPS on a Core i3 / integrated graphics

This folder is **MakeUp - Ultra Fast v9.6** by Javier Garduño (KDXavier), tuned
here for a Core i3 with **12 GB of RAM** and integrated graphics. It is not part
of SiraLite Shaders.

## Licence and credit

MakeUp is **GNU Lesser General Public License v3.0**. Its README grants use and
modification without restriction and asks for credit plus the official links if
you redistribute it:

- https://modrinth.com/shader/makeup-ultra-fast-shaders
- https://github.com/javiergcim/MakeUpUltraFast
- https://www.planetminecraft.com/mod/makeup-ultra-fast-shader/
- https://www.curseforge.com/minecraft/customization/makeup-ultra-fast-shader

`LICENSE` in this folder must stay with the pack. This tuned copy is kept out of
git (see `.gitignore`) because the two projects have different licences.

## Part 1 - the defaults

Every change is a value in `shaders/lib/config.glsl`, plus one profile and two
pass switches in `shaders/shaders.properties`. No shader logic was rewritten, so
the pack stays updatable and every effect can be switched back on from its own
options screen.

| Option | Was | Now | Why |
| --- | --- | --- | --- |
| `V_CLOUDS` | 1 (volumetric) | 0 (vanilla) | A raymarch at 10 samples per pixel plus cloud reflections: the single largest cost |
| `CLOUD_REFLECTION`, `END_CLOUDS` | on | off | Re-render the cloud layer again |
| `REFLECTION_SLIDER` | 2 (raymarched SSR) | 0 | Ten screen-space raymarch steps on reflective pixels |
| `AA_TYPE` | 2 (TAA + FXAA) | 0 | A history buffer and a full-screen resolve |
| `BLOOM` | on | off | Extra passes and a mipmap chain |
| `AO` | 1 (5 taps) | 0 | With AO off the pack falls back to vanilla's baked AO |
| `AOSTEPS` | 5 | 3 | Only matters if AO is re-enabled |
| `VOL_LIGHT` | 1 (godrays) | 0 | A depth-based screen-space march |
| `GODRAY_STEPS` | 6 | 4 | Same |
| `RAYMARCH_STEPS` | 10 | 5 | Same, for reflections |
| `CLOUD_STEPS_AVG` | 10 | 7 | Same, for volumetric clouds |
| `MATERIAL_GLOSS` | on | off | Per-pixel gloss on metal-like blocks |
| `REFRACTION`, `SUN_REFLECTION` | on | off | Water sampling |
| `COLORED_SHADOW` | on | off | Meaningless without a shadow pass |
| `SHADOW_CASTING` | on | **off** | A whole second scene render: the biggest single saving |
| `SHADOW_QTY_SLIDER`, `SHADOW_DISTANCE_SLIDER` | 2 / 1 | 1 / 0 | So re-enabling shadows is affordable (300 map, 75 blocks) |

Two passes are skipped when nothing in them can run:

- `program.composite1.enabled = BLOOM || DOF` - bloom and depth of field only.
- `program.composite2.enabled = AA_TYPE || MOTION_BLUR` - antialiasing and motion blur only.

A **MAX_FPS** profile at the top of the profile list restores all of this in one
click.

## Part 2 - what was checked in the code, and why it stops here

The obvious next step would be to delete passes. Before doing that, these were
read line by line:

1. **`deferred` cannot be removed.** With AO and volumetric clouds off it is
   almost a pass-through, but it writes `DRAWBUFFERS:14` - colortex**4**, which
   is `gaux4`, the fog colour that **every** block, entity, hand and water pixel
   samples in `src/finalcolor.glsl`. Removing it would break fog everywhere.
2. **`composite` is already lean.** With bloom off it writes `DRAWBUFFERS:16`:
   it does not touch the bloom buffer at all, only the scene and the exposure
   value that `final` tonemaps with.
3. **`final` skips everything it should.** Its second scene fetch, its
   `colortex2` fetch and its shadow/debug fetches all sit inside
   `#if CHROMA_ABER == 1`, `#if AA_TYPE == 3` and `#ifdef DEBUG_MODE` blocks, so
   with this configuration the pass is one fetch plus the tonemap.
4. **The terrain shader is already tight.** `solid_blocks_fragment.glsl` is one
   texture fetch and about twenty instructions: with shadows off the shadow
   lookup collapses to `abs(dayNightMix * 2.0 - 1.0)`, and the ambient-occlusion,
   gloss and material paths are compiled out. Its render-target writes are one or
   two buffers per program.
5. **The one `pow` in `composite` that looked expensive sits inside
   `if (isEyeInWater == 1)`** - a uniform branch, so it costs nothing on land.
   Changing it would have been a fake saving, so it was left alone.

Conclusion: there is no waste left to cut without changing the look. MakeUp's
author guards the expensive work correctly; what remains is four full-screen
passes and roughly one texture fetch per pixel, which is the shape of the pack.

## Part 3 - what is actually left for this machine

Ordered by effect per unit of effort. The first three matter more than anything
that can be done inside the shader.

1. **Resolution.** An integrated GPU is fill-rate bound: 1080p to 1600x900 is
   about 30% fewer pixels, 1280x720 about 55% fewer, and the picture still looks
   fine on a small monitor. The largest single lever.
2. **Render distance 8, simulation distance 5.** Every chunk is CPU work on an
   i3, and that is usually where the frame time actually goes.
3. **Allocate 4 GB, not more.** With 12 GB, Java only needs 3-4 GB here; the rest
   is better used by the integrated GPU as shared memory, which is exactly where
   this pack spends its bandwidth.
4. **`FOG_ACTIVE` off** - the last real per-pixel saving in the pack. That define
   gates one full-screen `gaux4` fetch on every block pixel; turning it off
   removes the fetch *and* the mix, at the cost of chunks popping at render
   distance with no distance haze. Turn it off to measure, decide with your eyes.
5. If you want beauty back, in this order: `REFLECTION_SLIDER = 1` (flipped-image
   water reflection, one screen read, no raymarch), then `AO = 1` with
   `AOSTEPS = 3`, then `AA_TYPE = 2` if foliage shimmer bothers you, then
   `SHADOW_CASTING` with the sliders left at 1 / 0.

## What has and has not been verified

- Verified by reading the code: the five findings in part 2, that every default
  above is a supported option of this pack, and that each skipped pass contains
  only the work named in its own guard.
- Not verified: framerate on your machine, and how it looks. Nothing here was run
  on a GPU. Measure with F3 before and after, and revert anything you dislike -
  each change is a single value.
