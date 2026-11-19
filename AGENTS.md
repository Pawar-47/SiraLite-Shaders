# AGENTS.md

This repository is an Iris shader pack for Minecraft Java Edition 1.21.5, written
in GLSL `#version 330 compatibility`. All shader content is in `shaders/`.
The Gradle setup is for development and packaging only.

## Architecture rules

- The pack is **forward rendered**. Terrain, entities and translucent geometry are
  lit in the gbuffers programs and written to `colortex0` only. Do not add a
  normals, specular or other extra render target: extra targets cost memory
  bandwidth, which is the scarcest resource on the target hardware.
- There is exactly **one post processing pass** (`composite`). There is no
  `deferred` pass - removing it saved a full-screen copy. Do not add
  `composite1+` or `final` passes without measuring the cost first.
- Common code lives in `shaders/lib/`. `common.glsl` holds uniforms and pure
  helpers, `lighting.glsl` the lightmap and lighting model, `shadow.glsl` the
  shadow lookup (compiled only when `SHADOW_QUALITY > 0`), `settings.glsl` every
  option.
- Never declare a uniform in an individual program if a lib already declares it.
  Duplicate declarations are a compile error.
- A uniform declared in a `lib/` file must be one that Iris binds for every
  program that includes it.

## Options

Every user option is a macro in `shaders/lib/settings.glsl`, nowhere else. Iris
requires an option to be defined identically in every file that uses it, so a
single home is the only safe approach.

When you add or rename an option, also update:

- `shaders/shaders.properties` (`screen`, `sliders`, and all three profiles).
- `shaders/lang/en_us.lang` (label and tooltip).

Never use a `float` option inside `#if`. Use an `int` option for `#if`, and a
boolean (`#ifdef`) for on/off. GLSL's `#if` is specified for integers only.

## Performance rules

- Cheap by default: a pixel should cost one texture fetch and one lightmap fetch
  unless a feature the user switched on says otherwise.
- No `pow`, `exp`, `log` or noise in a per-pixel path on the default preset.
  Multiplies, `dot`, `mix`, `step` and one `sqrt` are acceptable.
- No loops and no per-pixel branching on the default preset. Shadow and optional
  effect code is compiled out by option macros instead.
- Any new effect that cannot be switched off is paid for by every user of the
  default preset. Give it an option, or do not add it.

## Verify before claiming

- `bash tools/check_shaders.sh` - structural checks that need no GPU.
- `gradlew assemble` - produces `build/releases/siralite-shaders-<version>-shaderpack.zip`.
- `gradlew runShaderClient` - development client with the pack applied.

Nothing in CI or in those checks can prove a shader looks right or runs fast.
Only a real client on real hardware can. Do not write FPS figures, frame times or
"tested on <GPU>" claims into the documentation without measuring them.
