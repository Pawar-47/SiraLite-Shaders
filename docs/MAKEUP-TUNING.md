# Tuning a heavy shader pack for very weak hardware

Field notes from reducing **MakeUp - Ultra Fast v9.6** (GNU Lesser General Public
License v3.0, by Javier Garduño) to its cheapest configuration for an older
Intel Core i3 with 12 GB of RAM and integrated graphics, and then reading its
code to find out what was left to cut.

That pack is not redistributed here and is not part of this project: it lives in
a local `Ref/` folder which `.gitignore` keeps out of the repository, because the
two projects have different licences. Only the method and the findings are
recorded here. The pack itself:
<https://modrinth.com/shader/makeup-ultra-fast-shaders> and
<https://github.com/javiergcim/MakeUpUltraFast>.

## The method

1. **Find the defaults that cost the most, before touching a single line of
   GLSL.** A configurable pack ships its cost in option defaults, not in code.
   MakeUp's defaults ran volumetric clouds (10 samples per pixel), off-screen
   cloud reflections, raymarched screen-space reflections (10 steps), TAA + FXAA,
   bloom, ambient occlusion (5 taps), depth-based godrays and material gloss - on
   top of a full shadow pass. Turning those off is worth more than any
   micro-optimisation available afterwards.
2. **Look for passes that do nothing.** Two of its five post passes exist only
   for bloom/depth-of-field and for antialiasing/motion blur. With all four off,
   they are full-screen copies, so they can be disabled outright with
   `program.<name>.enabled`.
3. **Then read the code and check the obvious removals.** Before deleting a pass,
   prove what it produces and who consumes it.
4. **Write down the candidates that cannot be taken**, so the next person does not
   re-open them.

## What was checked in the code, and why the cuts stopped there

1. **`deferred` cannot be deleted.** With AO off and volumetric clouds on
   "vanilla", it is nearly a pass-through - but it writes `DRAWBUFFERS:14`, and
   colortex4 is `gaux4`, the fog colour that *every* block, entity, hand and water
   pixel samples in `src/finalcolor.glsl`. Removing it breaks fog everywhere.
2. **`composite` already writes only what it needs.** With bloom off it writes
   `DRAWBUFFERS:16`, so it never touches the bloom buffer. There is no dead write.
3. **`final` already skips its extra work.** Its second scene read, its colortex2
   read and its shadow/debug reads sit inside `#if CHROMA_ABER == 1`,
   `#if AA_TYPE == 3` and `#ifdef DEBUG_MODE`. With a low-end configuration the
   pass is one fetch plus the tonemap.
4. **The terrain shader is already tight.** One texture fetch then roughly twenty
   instructions: with shadows off the shadow lookup collapses to
   `abs(dayNightMix * 2.0 - 1.0)`, and the ambient-occlusion, gloss and material
   paths are compiled out. Render targets are one or two buffers per program.
5. **One `pow` that looked like a per-pixel cost was not one.** It sits inside
   `if (isEyeInWater == 1)`, a uniform branch, so it costs nothing on land.
   Rewriting it would have been a fake saving.

Conclusion: that pack guards its expensive work correctly, and with a low-end
configuration what remains is four full-screen passes and about one texture fetch
per pixel. That is the shape of the pack, not waste.

## The one per-pixel saving that was left

Distance fog costs one full-screen texture fetch on every block pixel, gated by
the pack's `FOG_ACTIVE` define. Turning it off removes the fetch and the mix, and
also removes the haze that hides the edge of your render distance - so it is a
taste and framerate trade, not a free win. It was exposed as a separate profile
rather than chosen for the user.

## What actually moves framerate on this class of machine

Ordered by effect per unit of effort, and none of it is in the shader:

1. **Resolution.** An integrated GPU is fill-rate bound. 1080p to 1600x900 is
   about 30% fewer pixels; to 1280x720 about 55% fewer.
2. **Render distance 8, simulation distance 5.** Chunk work is CPU, and on an i3
   that is usually where the frame time actually goes.
3. **Allocate 4 GB, not more.** With 12 GB, Java needs 3-4 GB for a pack like
   this; the rest is better left to the integrated GPU as shared memory, which is
   exactly where a heavy pack spends its bandwidth.
4. Then the per-effect switches above, cheapest first: shadows, volumetric clouds,
   screen-space reflections, TAA, bloom, ambient occlusion, godrays.

## The limit of these notes

Everything above was established by reading code and configuration. Nothing was
measured on a GPU: there are no framerate numbers here, and inventing them would
be worse than having none. The general shape of the advice - cut the passes, then
cut the pixels - is the part that transfers to any pack.
