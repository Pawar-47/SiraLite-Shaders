# Credits and attribution

## Where this project comes from

SiraLite Shaders started from `ascpixi/minecraft-shader-template`, a minimal
Iris shader development template for Minecraft 1.21.5.

Used from that template:

- The repository layout (`shaders/` at the root, one file pair per program).
- The file names of the gbuffers programs, and the convention of one
  `#version 330 compatibility` shader pair per program.
- The Gradle / Fabric Loom build and development run setup (`build.gradle`,
  `settings.gradle`, the wrapper, `.vscode/`), with only the project identity
  changed. The template itself notes that it is based on the official
  [ShaderLABS Base-330](https://github.com/shaderLABS/Base-330) template.

Not used from that template:

- All the GLSL in this pack. The template's shaders were pass-through
  implementations (texture times vertex colour times the vanilla lightmap, plus
  a copy pass for `composite` and `deferred`). SiraLite's lighting model,
  sky, water, shadow sampling, colour grading, fog, presets and option system
  were written for this project.
- `shaders.properties`, `shaders/lang/en_us.lang`, `pack.mcmeta`, the
  documentation and the CI workflow did not exist in the template.

## Licence of the starting template

At the time this project was cloned, the upstream template repository contained
no `LICENSE` file and GitHub reported no licence for it. There was therefore no
explicit licence granting or restricting reuse of its contents. What this
project took from it is listed above and is limited to project scaffolding and
build configuration; the shader code is original to this project.

If you are the author of the template and want the scaffolding attributed or
licensed differently, open an issue on this repository.

## This project's licence

The contents of this repository are released under the MIT licence. See
[LICENSE](LICENSE).

## Third party

- **Iris** and **Sodium** are not bundled here. They are pulled in by the Gradle
  build only as development runtime dependencies, so that
  `gradlew runShaderClient` can start a client with the pack applied.
- **Minecraft** is not bundled here and is not redistributed by this project.
