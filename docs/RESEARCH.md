# What SiraLite learned from, and what it did not copy

This file records the reference material behind the design decisions in this
pack, so the reasoning is auditable and no third party's work is silently
absorbed.

## How the reference material was found

The catalogue of record for Minecraft shader packs is
[Modrinth](https://modrinth.com/shaders). I queried its public API
(`api.modrinth.com/v2`) directly: a search over `project_type:shader` sorted by
downloads, then the project records for the packs of interest. That returns the
real licence of each project, which decided what was usable as reference.

The top of that list, and the licences, as of this writing:

| Pack | Downloads | Licence |
| --- | --- | --- |
| Complementary Reimagined | ~73M | custom |
| Complementary Unbound | ~48M | custom |
| BSL Shaders | ~32M | **All Rights Reserved** |
| Photon | ~29M | custom |
| Solas | ~19M | **All Rights Reserved** |
| Bliss | ~16M | **All Rights Reserved** |
| MakeUp - Ultra Fast | ~14M | LGPL-3.0-or-later |
| Mellow | ~8M | MIT |
| Miniature Shader | ~5M | MIT |

Only the openly licensed ones can be used as a source of study. The packs I read
are:

- **Miniature Shader** - MIT - https://github.com/mateuskreuch/minecraft-miniature-shader
  Read: `shaders/shader.h`, `shaders/dimension.properties`,
  `shaders/program/clouds.fsh`, `shaders/program/translucent.fsh`,
  `shaders/program/final.fsh`, and the file layout of `shaders/program/`.
- **MakeUp - Ultra Fast** - LGPL-3.0-or-later -
  https://github.com/javiergcim/MakeUpUltraFast
  Read: repository layout, `shaders/shaders.properties`, the per-feature
  structure (optional effects, per-dimension folders, `prepare`/`composite`
  chain).
- **Mellow** - MIT - https://codeberg.org/TheCMK/mellow-shader
  Read: the project description and feature list only (fog system, cloud
  styles, lightmap or shadowmap based shadows, colour grading tools).

No source file from any of these packs is included in this repository, and no
pack zip is redistributed here. Several of the most popular packs are
All-Rights-Reserved; committing one "for reference" into a public repository
would violate its licence, so reference material stays out of the repository.
That is a deliberate licensing decision, not an omission.

## Adopted, and how it differs here

1. **Clouds placed in the atmosphere** (from `program/clouds.fsh` in Miniature).
   They pull cloud colour toward `fogColor` and cut cloud alpha near the sun at
   sunrise and sunset. SiraLite does the same idea with its own arithmetic: a
   tint ramp by time of day, a 35% pull toward the horizon colour, and a silver
   lining brightened by the cosine to the sun or moon. Brightening rather than
   alpha-cutting, because our clouds are vanilla geometry and we cannot reshape
   them.

2. **Shadows tinted toward blue** (their `SHADOW_COLOR` = darkness plus a blue
   bias). SiraLite reached the same conclusion independently in 1.2.0 with
   `shadeTint`; their ramp informed the values, and the effect is applied as a
   colour mix in `shadeLit` instead of a shadow colour buffer.

3. **`entityShadowDistanceMul`** (their constant, default 0.2). Adopted as 0.25:
   entities only cast shadows near the player, which removes most entity
   geometry from the shadow pass. This is a real, measurable saving when shadows
   are switched on.

4. **`shadowIntervalSize`** (their constant, default 7.0). Adopted: it dithers
   where the shadow map is sampled and softens the banding that a 1024 map shows
   on long shadows.

5. **Torch light that changes with distance from the torch.** They sample the
   lightmap at fixed UVs three times to get inner, middle and outer torch
   colours. SiraLite keeps its single lightmap fetch and shifts the tint from
   warm white to orange by the block light level squared, which reaches a
   similar look for two multiplies instead of two extra fetches.

6. **Handheld light** (their `HAND_DYNAMIC_LIGHTING`, from
   `heldBlockLightValue`). Adopted with a uniform branch, so carrying nothing
   costs one comparison, and a 13 block falloff squared.

7. **Per-dimension behaviour.** They split programs into `world0/`, `world-1/`
   and `world1/` folders with a three line `dimension.properties`. SiraLite
   does the same job with uniform branching instead: Iris exposes `hasSkylight`
   and `hasCeiling`, which identify all three dimensions (Overworld: sky light;
   Nether: no sky light, ceiling; End: no sky light, no ceiling). That avoids
   duplicating a dozen programs and any dependence on how missing per-dimension
   files fall back.

## Considered and deliberately rejected

- **Screen-space reflections** (Miniature's `final.fsh`: a normal and
  reflectivity buffer plus a bounded ray march in screen space). It needs two
  extra render targets and a full-screen ray march per pixel. On integrated
  graphics that is precisely the bandwidth and fill rate this pack exists to
  avoid. SiraLite keeps the analytic sky reflection.
- **Multiple colour targets** (their `DRAWBUFFERS:067` normals/reflectivity
  targets). One target is the pack's core budget decision.
- **Per-dimension program folders.** Replaced by uniform branching, see above.
- **Temporal antialiasing, depth of field, motion blur, volumetric clouds,
  auto exposure** (MakeUp's optional feature list). Every one of them costs more
  per frame than this pack's entire budget on an older i3 with integrated
  graphics. MakeUp makes them optional and that is the right design for a
  high-end machine; for this target they are off the table.
- **Textures, noise maps, cloud sprites.** Neither pack needs them for the
  effects above, and every image costs VRAM and sampling bandwidth.

## What this means for the licence

SiraLite Shaders is MIT. The ideas above are techniques and parameter ranges,
reimplemented in this repository's own code; where a specific constant was
adopted (the two shadow constants), that is stated here. If any author of the
packs above believes something here is too close to their work, open an issue
and it will be changed or credited.
