# SiraLite Shaders 1.7.0

A small release on top of 1.6.0. The pack already had everything 1.6.0
described; this version exists so the current state has its own download, and
adds the one free control that came out of tuning another pack.

## New

- **Corner Shading** (`ambientOcclusionLevel`, default `0.30`): how dark
  vanilla's baked ambient occlusion gets in corners and along edges. It costs
  nothing either way - those shadows are already in the vertex data - so it is a
  pure look control in the Lighting screen.

## Why this release exists

1.6.0 published correctly, with its zip attached, and CI has been green since.
The only change after it was keeping a third-party reference pack out of git, and
that does not alter the shader - so rather than leave the download behind the
source, the version was bumped and republished with the new control.

## Unchanged guarantees

- Ultra Performance stays the default; Potato is still the floor.
- Every effect has an option, and every profile is one click.
- Releases are additive: v1.6.0, v1.5.0, v1.4.0, v1.3.0 and v1.2.0 all stay
  published with their downloads untouched.
