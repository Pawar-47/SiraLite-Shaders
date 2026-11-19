# SiraLite Shaders 2.2.0

Two things: a profile that takes the pack to the top of everything it implements,
and a file-by-file answer to "did you take everything from BSL?"

## New: the `BSL_MAX` profile

The fourth profile, and the ceiling. It sets every effect this pack implements to
the highest value its own option list allows, with nothing held back:

- Shadows at **4080 x 4080 over 255 blocks** - `SHADOW_DISTANCE_SLIDER` 2 with
  `SHADOW_QTY_SLIDER` 3, straight out of the resolution table in
  `shaders/lib/config.glsl`, with coloured shadows on.
- **Raymarched screen-space reflections** (`REFLECTION_SLIDER` 2), on top of water
  refraction and sun glint.
- **Dynamic volumetric clouds** (`V_CLOUDS` 2) with their water reflection and
  clouds drawn in the End, plus **true volumetric light** (`VOL_LIGHT` 2).
- **TAA + FXAA** (`AA_TYPE` 3), **AO at 8 samples**, **5-sample-pair bloom**,
  material gloss.
- No colour grade change: it keeps whatever the pack's Colour scheme is set to.

For screenshots, or a discrete GPU. On integrated graphics it will not hold a
playable framerate - that is what `MAX_FPS`, the default, is for.

## The BSL question, answered with files

`Custom/` is BSL Shaders v10 by Capt Tatsu. Its own published terms, from the
Modrinth project page, allow using and **modifying it for personal use**, and allow
publishing a modified version only **"with my permission"**; they forbid
**redistributing it without permission** and claiming its code as your own. The
project's licence field is `LicenseRef-All-Rights-Reserved`, and `Custom/` contains
no licence file at all.

So no BSL source is copied, renamed or repackaged here, and none will be: what this
repository ships is MakeUp - Ultra Fast, LGPL-3.0-or-later, which is what makes a
public release of this pack lawful in the first place. What BSL does allow -
personal modification - is exactly what `Local/bsl/` is for, on your own machine.

`docs/FEATURE-PARITY.md` now goes through BSL's tree module by module. `Custom/lib/`
holds 50 modules plus `settings.glsl`; of those 50, **22 have an equivalent here, 2
are partly covered, and 22 do not exist at all** - rain puddles, lens flare,
outlines, coloured block light, parallax occlusion mapping, GGX specular, a material
G-buffer, world curvature, chunk fade, weather density, aurora, specular colour and
VoxelMap colour fetch among them. That file also says what each missing one would
take to build, and why nothing was written blind: there is no GPU here, so an
untested feature would just be broken code behind a version number.

## Install

1. Fabric Loader for Minecraft 1.21.5, plus Iris 1.8.x (Sodium recommended).
2. Drop `siralite-shaders-2.2.0-shaderpack.zip` into `shaderpacks/`. Do not unzip.
3. Options > Video Settings > Shader Packs > apply the pack, open its settings, and
   pick a profile: **MAX_FPS** (default, cheapest), **MAX_FPS_NOFOG**,
   **BSL Inspired** (survivable full look) or **BSL Max** (everything at maximum).

## Licence

Unchanged: `shaders/` is **LGPL-3.0-or-later**, because it is a modified version of
MakeUp - Ultra Fast v9.6 by Javier Garduño. The licence text ships in the zip, and
`NOTICE.md` lists every change with its date. Everything else in the repository -
the build, the checks, the docs, the previous 1.x pack - remains MIT.

## Honest note

Nobody has run this on a GPU here, so no framerate numbers are claimed. `BSL_MAX` is
one line in `shaders/shaders.properties`, and each of its values is a token from the
pack's own option list or its shadow-resolution table - nothing was estimated.
