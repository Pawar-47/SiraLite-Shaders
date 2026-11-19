# SiraLite Shaders 2.1.0

A BSL-inspired preset, in the same pack. No shader logic was touched, no file was
removed, and the shipped defaults are still the cheapest configuration of the pack:
if you never open the profile menu, 2.1.0 behaves exactly like 2.0.0.

## What is new

- **`BSL_INSPIRED` profile.** The look a BSL-class pack gives you, assembled from
  MakeUp's own implementations of the same effects and switched on in one click:
  sun shadows at 840² over 105 blocks, coloured shadows, volumetric clouds with
  water and End reflection, volumetric light, bloom, TAA, ambient occlusion at 5
  samples, water refraction, sun glint on water and glass, flipped-image water
  reflection, material gloss, waving, and a warm colour grade.
- **Labelled in all nine languages** the pack ships, so the entry reads properly
  whichever language Iris runs in.
- **Three profiles at the ends of the range now:** `MAX_FPS` (default, everything
  off), `MAX_FPS_NOFOG` (that, plus distance fog off) and `BSL_INSPIRED`
  (everything on). MakeUp's own ladder - No effects through High (DoF) - is
  unchanged.

## Why a preset and not BSL itself

BSL Shaders is All Rights Reserved, so this repository cannot ship, modify and
publish it. What it can publish is the LGPL base it already carries: MakeUp has its
own sun and moon reflection, volumetric clouds, volumetric light, coloured shadows
and TAA. `BSL_INSPIRED` switches those on together, at values chosen to be
survivable rather than maximal.

## What it costs

Shadows are a second scene render; the volumetric clouds raymarch per sky pixel and
their reflection adds a second cloud render; TAA adds a history buffer and a
full-screen resolve; bloom and volumetric light are extra passes. Deliberately left
off in this preset: reflection raymarching (`REFLECTION_SLIDER` 2), dynamic clouds
(`V_CLOUDS` 2), depth of field, motion blur, and MakeUp's higher shadow resolutions.
Each is one slider on the Advanced options screen.

If it is too slow, set the profile back to `MAX_FPS` and switch effects on one at a
time - the README has the order, cheapest first.

## Install

1. Fabric Loader for Minecraft 1.21.5, plus Iris 1.8.x (Sodium recommended).
2. Drop `siralite-shaders-2.1.0-shaderpack.zip` into `shaderpacks/`. Do not unzip.
3. Options > Video Settings > Shader Packs > apply the pack, open its settings, and
   pick **BSL Inspired** in the profile menu.

## Licence

Unchanged: `shaders/` is **LGPL-3.0-or-later**, because it is a modified version of
MakeUp - Ultra Fast v9.6 by Javier Garduño. The licence text ships in the zip, and
`NOTICE.md` lists every change with its date. Everything else in the repository -
the build, the checks, the docs, the previous 1.x pack - remains MIT.

## Honest note

Nobody has run this on a GPU here, so no framerate numbers are claimed. The profile
is a single line in `shaders/shaders.properties`, its values come from the pack's
own option list and its shadow-resolution table in `shaders/lib/config.glsl`, and
every one of them is a token you can change from the Advanced options screen.
