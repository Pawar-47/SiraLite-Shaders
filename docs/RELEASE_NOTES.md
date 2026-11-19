# SiraLite Shaders 1.5.0

## Fixed

- **The cloud-like artifact in the sky is gone.** It was the experimental high
  cirrus layer added in 1.3.0: a sine pattern projected by `dir.xz / dir.y`,
  which bunches up into streaks near the horizon and reads as a smear rather than
  as cloud. The layer and its option are removed. The sky is now exactly one
  analytic gradient plus the sun and moon: nothing in it can look like a shape
  that is not there.

## Settings reorganized

The option screens now follow the five groups players actually look for:

- **Lighting** - brightness, night level, sunset warmth, fog, cloud shading,
  handheld light, dimension tuning
- **Shadows** - quality, resolution, distance, interval, entity shadow distance,
  strength
- **Ray Tracing** - water reflections and strength, water waves, water depth,
  underwater caustics, sun glare, ambient occlusion. Named plainly: this pack has
  no ray tracing. The screen gathers the light-transport approximations, and the
  ambient occlusion is the one real screen-space march in the pack.
- **Colour Settings** - saturation, contrast, colour balance, vignette
- **Performance** - the post pass switch, bloom, waving plants and water, wave
  strength, vegetation polish

## New

- **Colour Balance** (`COLOR_WARMTH`, default 0.5): one number from cool and blue
  through neutral to warm and golden, replacing the fixed warm/cool split.

## About stripping Complementary Unbound

It was asked for, and it was checked. The Complementary Agreement 1.3 does permit
redistributing a modified pack, but 1.3(d) requires the modified pack to "look
noticeably different ... in multiple common gameplay scenarios that must include
daytime overworld visuals". A copy with effects disabled for performance is the
same look, so it fails that clause and is not published. Use Complementary
Unbound's own **Potato** profile instead - that is the author's low-end
configuration. The full reasoning and the quoted clause are in
`docs/RESEARCH.md`.

## Upgrade policy

Releases are additive. This release is new; v1.4.0, v1.3.0 and v1.2.0 stay
published with their downloads untouched.
