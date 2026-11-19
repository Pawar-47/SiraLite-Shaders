# SiraLite Shaders 1.4.0

Dimensions, clouds that belong to the sky, and a usable torch. This release came
out of reading the openly licensed packs published on Modrinth - see
`docs/RESEARCH.md` for exactly what was studied, adopted and rejected, and why
no third party pack is redistributed here.

## New

- **Dimension tuning.** The Nether now gets warm light and thick haze, the End
  cool light and clear air, instead of both looking like the Overworld at night.
  Done by branching on `hasSkylight` and `hasCeiling`, so there is no duplicated
  program for each dimension.
- **Clouds in the atmosphere.** Cloud colour is pulled 35% toward the horizon
  colour, so clouds sit in the air instead of looking pasted on the sky, and a
  silver lining appears where a cloud faces the sun or moon, strongest at
  sunrise and sunset.
- **Handheld light.** A torch or lantern in your hand lights the ground around
  you within 13 blocks. Carrying nothing costs one comparison.
- **Torch light that deepens with distance.** Warm white close to the source,
  orange across the room, from the block light level.
- **Two new shadow controls**, both adopted from an established pack's approach:
  `entityShadowDistanceMul` (entities only cast shadows near you, which removes
  most entity geometry from the shadow pass) and `shadowIntervalSize` (softer
  banding on a 1024 shadow map).

## Unchanged guarantees

- Ultra Performance stays the default: no shadow pass, one post pass, two
  texture fetches per terrain pixel.
- Every effect has an option and can be switched off on its own.

## Upgrade policy

Releases are additive. Publishing this version creates a new release and leaves
the previous ones, and their downloads, untouched: nothing is deleted or
retagged.
