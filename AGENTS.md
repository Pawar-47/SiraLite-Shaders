# AGENTS.md

This repository ships a **modified version of MakeUp - Ultra Fast v9.6** in
`shaders/`. That directory is **LGPL-3.0-or-later** and is someone else's code.
Everything else here - build files, checks, docs - is MIT.

Read [NOTICE.md](NOTICE.md) before changing anything under `shaders/`.

## Rules for `shaders/`

- **Do not rewrite upstream logic.** The value of this repository is an unmodified
  pack with retuned defaults. Changing shader code means diverging from a pack its
  author maintains, and it must then be documented as a change in `NOTICE.md`.
- **Allowed changes are narrow:** option defaults in `shaders/lib/config.glsl`,
  profiles and `program.<name>.enabled` switches in `shaders/shaders.properties`,
  and one `profile.<name>=` label line per language in `shaders/lang/*.lang` for a
  profile added there. That is the whole tuning surface, and `Ref/OPTIMIZED.md`
  records every value that was already changed.
- **Keep the licence and notice accurate.** If you modify anything under
  `shaders/`, add it to the dated list in `NOTICE.md`. The LGPL requires it, and
  `LICENSE-LGPL-3.0.txt` must keep shipping inside the built zip (it does, via the
  `LICENSE*` include in `build.gradle`).
- **Keep the unmodified original intact** in `Ref/shaders/` so differences stay
  diff-able. Never edit `Ref/shaders/`; copy changes into `shaders/` only.

## Checks

`bash tools/check_shaders.sh` - structural only: `#version` on entry points, entry
points include a body, preprocessor conditionals balance, includes resolve. It is
not a GLSL compiler and cannot tell you whether the pack compiles on a GPU, looks
right or runs fast. Do not claim otherwise.

`gradlew assemble` builds `build/releases/*.zip`; CI also publishes it as a
release on every push.

## Honesty rules

- No framerate numbers, no "tested on <GPU>" claim, unless someone actually
  measured it. Nothing in this repository has been benchmarked.
- Do not describe a config change as an optimisation without saying whether it was
  verified by reading code or by measurement.

## The legacy pack

`legacy/siralite-shaders/` is the previous MIT pack. It is not built, not
packaged, and not scanned by the checks. Leave it alone unless specifically asked.
