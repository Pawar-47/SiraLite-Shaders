/*
    SiraLite Shaders - vegetation and water motion.

    Vertex stage only. A sway costs two sine calls per vertex and nothing at
    all per pixel, which is the only kind of motion this pack can afford on
    hardware that cannot afford another full-screen effect.

    Block ids come from shaders/block.properties, which Iris hands to the
    chunk vertex shaders as mc_Entity.x. A block with no mapping has an id
    outside the ranges below, so unlisted blocks never move and nothing
    breaks if block.properties is not loaded.
*/

#ifndef SIRALITE_WAVING_GLSL
#define SIRALITE_WAVING_GLSL

#include "/lib/settings.glsl"

// Must match the ids in shaders/block.properties.
#define SIRALITE_ID_PLANT 10001.0
#define SIRALITE_ID_LEAVES 10002.0
#define SIRALITE_ID_WATER 10003.0

/* frameTimeCounter, chunkOffset and mc_Entity are declared here rather than in
   lib/common.glsl: only vertex shaders include this file, and a uniform may
   not be declared twice in one program. */
uniform float frameTimeCounter;
uniform vec3 chunkOffset; // player space offset of the chunk being drawn

float isWaterId(float blockId) {
	return (blockId > SIRALITE_ID_WATER - 0.5 && blockId < SIRALITE_ID_WATER + 0.5) ? 1.0 : 0.0;
}

/* How much of the sway a vertex gets: 0 stays anchored, 1 travels fully.
   heightFrac pins the base of a plant so its roots do not slide across the
   ground; leaves move as a whole block instead. */
float swayAmount(float blockId, float heightFrac) {
	if (blockId > SIRALITE_ID_PLANT - 0.5 && blockId < SIRALITE_ID_PLANT + 0.5) {
		return heightFrac;
	}
	if (blockId > SIRALITE_ID_LEAVES - 0.5 && blockId < SIRALITE_ID_LEAVES + 0.5) {
		return 0.75;
	}
	return 0.0;
}

/* Two waves on a phase taken from world position, so neighbouring plants are
   out of step with each other instead of the whole forest pulsing at once. */
vec3 swayOffset(vec3 anchor, float amount) {
	float t = frameTimeCounter * 1.6;
	float phase = anchor.x * 0.7 + anchor.z * 0.9;
	float swingX = sin(phase + t);
	float swingZ = cos(phase * 0.8 + t * 0.85);
	return vec3(swingX * 0.055, 0.0, swingZ * 0.04) * (amount * WAVE_STRENGTH);
}

/* Displaced model space position for vegetation. Returns the input unchanged
   for anything that is not vegetation. */
vec3 waveVegetation(vec3 modelPos, float blockId) {
#ifdef WAVING_PLANTS
	float amount = swayAmount(blockId, clamp(modelPos.y, 0.0, 1.0));
	if (amount > 0.0) {
		return modelPos + swayOffset(modelPos + chunkOffset, amount);
	}
#endif
	return modelPos;
}

/* Vertical displacement for the water surface. Only the upper part of the
   block moves, so a water column does not tear away from the block below it,
   and the amplitude stays small enough not to open gaps at the shoreline. */
float waveWater(vec3 modelPos, float blockId) {
#ifdef WAVING_WATER
	if (isWaterId(blockId) > 0.5) {
		float top = clamp((modelPos.y - 0.4) * 2.0, 0.0, 1.0);
		return sin((modelPos.x + chunkOffset.x) * 0.9 + frameTimeCounter * 1.1) *
		       0.03 * top * WAVE_STRENGTH;
	}
#endif
	return 0.0;
}

#endif
