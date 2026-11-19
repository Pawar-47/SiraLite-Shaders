# BSL parity, file by file

This is the answer to one question: **what is in `Custom/` that is not in the pack
this repository ships?** It is written from the two file trees themselves, not from
memory, and every entry can be checked by opening the named file.

Two directories matter:

- `Custom/` - BSL Shaders v10 Series by Capt Tatsu, the reference copy used to
  study BSL's approach. Not tracked by git, never packaged.
- `shaders/` - MakeUp - Ultra Fast v9.6, modified, LGPL-3.0-or-later. The pack
  that is built and released.

## Why nothing was copied out of `Custom/`

BSL's own published terms, as of the Modrinth project page
(`api.modrinth.com/v2/project/bsl-shaders`, field `body`), say:

> You're allowed to... Modify the shaderpack for personal use. Publish your
> heavily modified version of the pack with my permission.
>
> You're not allowed to... Redistribute the shaderpack without my permission.
> Claim (and rename) my shaderpack (or its code) as your own.

The Modrinth project's licence field is `LicenseRef-All-Rights-Reserved`, and no
licence file exists anywhere inside `Custom/` (searching every file there for
licence, copyright, permission or "all rights reserved" returns nothing).

So the two things that are allowed are personal modification and asking for
permission. Copying BSL's files into a public repository, or republishing a
renamed copy of its code, is exactly what those terms forbid, and a public
repository is what this is. That is the whole reason `Custom/` is gitignored.

## What this pack has, by BSL module

Symbols: **yes** - the feature exists here (the right-hand column names our file,
which is a different implementation unless it says otherwise); **no** - the feature
does not exist anywhere in `shaders/`; **partly** - some of it exists.

| BSL module (`Custom/lib/...`) | In `shaders/` | Where / what instead |
| --- | --- | --- |
| `antialiasing/fxaa.glsl` | yes | `lib/fxaa.glsl` |
| `antialiasing/taa.glsl` | yes | `lib/fast_taa.glsl`, a different temporal filter |
| `atmospherics/clouds.glsl` | yes | `lib/volumetric_clouds.glsl` + `_end`, raymarched rather than BSL's layered sheet model |
| `atmospherics/lightShafts.glsl` | yes | `lib/volumetric_light.glsl` |
| `atmospherics/fog.glsl` | yes | fog is built in `src/fog_vertex.glsl` and `lib/basic_utils.glsl`, organised differently |
| `atmospherics/sky.glsl` | yes | `src/hi_sky.glsl`, `src/low_sky.glsl`, `lib/color_utils*.glsl` |
| `atmospherics/sunmoon.glsl` | partly | the sun and moon are drawn through `gbuffers_skytextured`; there is no separate sun/moon module |
| `atmospherics/waterFog.glsl` | partly | water absorption and tint are in `lib/water.glsl`; there is no distinct underwater fog layer |
| `atmospherics/chunkFade.glsl` | **no** | nothing fades chunk edges |
| `atmospherics/weatherDensity.glsl` | **no** | no per-weather density control |
| `color/auroraColor.glsl` | **no** | no aurora |
| `color/blocklightColor.glsl`, `lighting/coloredBlocklight.glsl` | **no** | block light is one temperature (`BLOCKLIGHT_TEMP`), not a colour per block type |
| `color/dimensionColor.glsl`, `endColor.glsl`, `netherColor.glsl`, `lightColor.glsl`, `lightSkyColor.glsl`, `skyColor.glsl`, `waterColor.glsl` | yes | `lib/color_utils.glsl`, `color_utils_end.glsl`, `color_utils_nether.glsl`, `lib/day_blend.glsl` |
| `color/specularColor.glsl` | **no** | no specular colour path; see GGX below |
| `lighting/ambientOcclusion.glsl` | yes | `lib/ao.glsl` |
| `lighting/dynamicHandlight.glsl` | yes | `DYN_HAND_LIGHT` option, applied in the hand and entity programs |
| `lighting/forwardLighting.glsl` | yes | forward lighting happens inline in `common/solid_blocks_fragment.glsl` and friends |
| `lighting/shadows.glsl` | yes | `lib/shadow_frag.glsl` + `lib/shadow_vertex.glsl` |
| `lighting/voxelColorFetch.glsl` | **no** | no VoxelMap colour compatibility |
| `post/lensFlare.glsl` | **no** | no lens flare |
| `post/outline.glsl`, `util/outlineDepth.glsl`, `outlineMask.glsl`, `outlineOffset.glsl` | **no** | no entity/block outlines |
| `reflections/simpleReflections.glsl` | yes | `REFLECTION_SLIDER` 1, the flipped-image reflection, in `lib/water.glsl` |
| `reflections/raytrace.glsl`, `roughReflections.glsl` | yes | `REFLECTION_SLIDER` 2, screen-space raymarching in `lib/water.glsl`. One module here, two there |
| `reflections/complexFresnel.glsl` | yes | fresnel maths inside `lib/water.glsl` |
| `reflections/rainPuddles.glsl` | **no** | no wet-surface puddles |
| `surface/ggx.glsl` | **no** | no GGX/roughness BRDF; the only surface response is `lib/material_gloss_fragment.glsl`, a flat gloss term |
| `surface/parallax.glsl` | **no** | no parallax occlusion mapping |
| `surface/materialGbuffers.glsl`, `materialDeferred.glsl`, `directionalLightmap.glsl`, `hardcodedEmission.glsl` | **no** | no material G-buffer or deferred material pass. MakeUp shades forward into one buffer |
| `util/voxelMap.glsl`, `voxelMapHelper.glsl` | **no** | no VoxelMap bridge |
| `vertex/waving.glsl` | yes | waving lives in `src/light_vertex.glsl` and `common/*_vertex.glsl` |
| `vertex/worldCurvature.glsl` | **no** | no world curvature |

Programs:

| BSL program | In `shaders/` |
| --- | --- |
| `composite.glsl` .. `composite7.glsl` | yes in kind: `composite`, `composite1`, `composite2`. Four passes fewer, and the ones that exist do different work |
| `deferred.glsl`, `deferred1.glsl` | yes in kind: `deferred`. No second deferred pass |
| `dh_terrain.glsl`, `dh_water.glsl` | yes, same names, Distant Horizons support |
| `voxy_opaque.glsl`, `voxy_translucent.glsl` | yes, same names, Voxy support |
| `shadow.glsl`, `shadowcomp.glsl` (compute) | yes, same names, compute shadow compositing included |
| `final.glsl`, `gbuffers_*` | yes, same names |

Data files:

| BSL | In `shaders/` |
| --- | --- |
| `block.properties` (392 lines), `entity.properties`, `item.properties`, `dimension.properties` | yes, as `shaders/block.properties` (102 lines) and the others |
| `lang/en_US.lang` (1180 lines: about 200 options) | yes, `shaders/lang/` in nine languages, about 60 options |

## Counting it honestly

`Custom/lib/` holds 50 modules plus `settings.glsl`. Of those 50: **22 have an
equivalent here, 2 are partly covered, and 22 do not exist at all**. The remaining
four - `dither`, `encode`, `jitter`, `spaceConversion` - are plumbing that both
packs implement in their own way, so they are not compared.

The 22 missing ones are the ones with no MakeUp counterpart to configure: puddles,
lens flare, outlines (and its three helper files), coloured block light, parallax,
GGX specular, a material G-buffer (four files), world curvature, chunk fade,
weather density, aurora, specular colour and VoxelMap colour fetch.

## What "at par with BSL" would actually take

The published pack already runs every effect it implements at maximum values -
that is the `BSL_MAX` profile. Closing the rest of the gap is not a copy job; it is
thirteen features, spread over the 22 missing files, written from scratch in this
codebase's pipeline, and each one touches more than one file:

- **Cheap and self-contained:** lens flare (a post pass on the sun position), chunk
  fade (one multiply at the edge of the render distance), world curvature (a vertex
  offset).
- **Medium:** rain puddles (needs a wetness uniform plus a gloss/specular response,
  which needs GGX first), outlines (a depth and mask pass), coloured block light
  (a second lookup in the lightmap path).
- **Expensive:** GGX plus normal mapping (a material G-buffer, a deferred material
  pass, and every forward program rewritten to read it), parallax (the same, plus
  resource-pack heightmaps).

None of that can be verified from here: there is no GPU in this environment, so a
feature written blind would be broken code shipped under a version number. The
honest order of work is one feature at a time, each one compiled in Iris and looked
at in game before the next is started.
