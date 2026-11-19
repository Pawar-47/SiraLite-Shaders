# Notice: licences and provenance

This repository ships **two different things under two different licences**. They
are kept separate on purpose; read this before reusing anything.

| Path | What it is | Licence |
| --- | --- | --- |
| `shaders/` | The shader pack that is built and released. A modified version of **MakeUp - Ultra Fast v9.6** | **LGPL-3.0-or-later** |
| `LICENSE-LGPL-3.0.txt`, `Ref/LICENSE` | The full text of that licence | LGPL-3.0 |
| `legacy/siralite-shaders/` | The previous, independently written SiraLite pack (1.x), kept for reference | MIT |
| Everything else (`docs/`, `tools/`, `build.gradle`, CI, `README.md`, this file) | Build tooling, checks and documentation | MIT |

## `shaders/` is a modified version, not the original

`shaders/` is a derivative of **MakeUp - Ultra Fast v9.6** by **Javier Garduño
(KDXavier)**:

- Modrinth: https://modrinth.com/shader/makeup-ultra-fast-shaders
- Source: https://github.com/javiergcim/MakeUpUltraFast
- Planet Minecraft: https://www.planetminecraft.com/mod/makeup-ultra-fast-shader/
- CurseForge: https://www.curseforge.com/minecraft/customization/makeup-ultra-fast-shader

In line with the LGPL's requirement that modified versions carry a notice of what
was changed and when:

**Modified on 2026-11-19.** The changes are:

1. `shaders/lib/config.glsl` - defaults retuned for an older Intel Core i3 with
   integrated graphics: shadows, volumetric clouds and cloud reflections,
   raymarched reflections, TAA, bloom, ambient occlusion, godrays, material
   gloss, refraction and sun reflection are off by default; shadow sliders and
   the sampling counts for the effects that remain are set to their cheapest
   values; `sunPathRotation` left as shipped.
2. `shaders/shaders.properties` - two profiles added (`MAX_FPS` and
   `MAX_FPS_NOFOG`), and `program.composite1.enabled` / `program.composite2.enabled`
   made conditional so those passes are skipped when bloom, depth of field,
   antialiasing and motion blur are all off. All of the pack's own profiles are
   unchanged.
3. `shaders/shaders.properties` and `shaders/lang/*.lang` (2.1.0) - a third profile,
   `BSL_INSPIRED`, which switches every effect the tuned defaults leave off back on
   at once, plus a label for it in each of the nine shipped languages. The pack's
   own profiles and its option code are untouched.
4. `shaders/shaders.properties` and `shaders/lang/*.lang` (2.2.0) - a fourth
   profile, `BSL_MAX`, which sets every option this pack implements to the highest
   value its own list allows, plus its label in the nine languages.
5. Nothing else. No shader logic was rewritten, no file was removed, and no
   texture was altered.

The unmodified upstream copy this was taken from is kept in `Ref/` for comparison,
and `Ref/OPTIMIZED.md` records the reasoning behind each value.

## Why the shader files are not MIT

The LGPL requires that the modified work as a whole stays under the LGPL, and that
its licence travels with it. That is why the licence file is shipped inside the
release zip alongside `shaders/`. The rest of this repository - the build, the
checks, the documentation, and the previous 1.x pack - remains MIT, and none of
that code is inside `shaders/`.

## If you only want the MIT part

Use `legacy/siralite-shaders/` and the tooling: those are MIT, see `LICENSE`. The
built release, however, packages `shaders/`, so a release zip is an LGPL-3.0 work.
