# Credits and attribution

This repository is **two things under two licences**. See [NOTICE.md](NOTICE.md)
for the exact split; this file is about who made what.

## The shader pack in `shaders/`

**MakeUp - Ultra Fast v9.6** by **Javier Garduño (KDXavier)**,
**GNU Lesser General Public License v3.0**.

- https://modrinth.com/shader/makeup-ultra-fast-shaders
- https://github.com/javiergcim/MakeUpUltraFast
- https://www.planetminecraft.com/mod/makeup-ultra-fast-shader/
- https://www.curseforge.com/minecraft/customization/makeup-ultra-fast-shader

It is included as a **modified version** for low-end hardware, as the LGPL allows
and asks: the licence file ships with it (`LICENSE-LGPL-3.0.txt`), and the list of
changes with its date is in [NOTICE.md](NOTICE.md). The unmodified copy this was
taken from is in `Ref/`, and `Ref/OPTIMIZED.md` records why each value changed.

Everything that makes this pack look the way it does - the lighting model, water,
sky, clouds, fog, the TAA and reflection code, the per-dimension programs - is
Javier's work, not mine.

## The previous pack in `legacy/siralite-shaders/`

The SiraLite Shaders 1.x pack: an independently written, MIT-licensed pack built
on `ascpixi/minecraft-shader-template` (itself based on the ShaderLABS Base-330
template). Kept for reference; it is no longer the shipped pack. Its history is
in git and its builds are still on the releases page as v1.2.0 to v1.7.1.

## Build tooling

The Gradle/Loom development setup comes from `ascpixi/minecraft-shader-template`
and is unchanged apart from the project identity. The release workflow, the
structural check script, the documentation in `docs/` and the tuning itself were
written for this repository, under MIT.

## Reference material studied

Recorded so the reasoning is auditable and nothing is silently absorbed:

- **Complementary Shaders - Unbound** (custom licence) - downloaded and read
  through its public source repository. Notes: [docs/RESEARCH.md](docs/RESEARCH.md).
- **MakeUp - Ultra Fast** (LGPL-3.0) - the pack now shipped, and the subject of
  [docs/MAKEUP-TUNING.md](docs/MAKEUP-TUNING.md).
- **Mellow** (MIT) - feature list and design notes only.

## Third party

- **Iris** and **Sodium** are not bundled. The Gradle build pulls them in as
  development runtime dependencies only, so `gradlew runShaderClient` can start a
  client with the pack applied.
- **Minecraft** is not bundled and is not redistributed by this project.
