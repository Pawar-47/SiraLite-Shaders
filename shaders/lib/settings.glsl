/*
    SiraLite Shaders - user options

    Iris builds the "Shader Pack Settings" screen by scanning
    "#define NAME value // [values] description" lines and
    "//#define NAME // description" lines. An option has to be defined
    identically in every program that uses it, so every option lives here
    and this file is included everywhere. Do not define options elsewhere.

    The defaults below are exactly the "Ultra Performance" profile.
*/

#ifndef SIRALITE_SETTINGS_GLSL
#define SIRALITE_SETTINGS_GLSL

/* ------------------------------------------------------------------ *
 *  SHADOWS
 *  Off by default. The shadow pass re-renders all terrain and entities
 *  from the light's point of view; it is the most expensive thing this
 *  shader can do, so the fastest default has no shadow pass at all.
 * ------------------------------------------------------------------ */

#define SHADOW_QUALITY 0 // [0 1 2] Shadow quality: 0 = off (no shadow pass), 1 = hard shadows, 2 = soft shadows (4 taps)
const int shadowMapResolution = 1024; // [512 1024 2048] Shadow map resolution. 1024 is the recommended low-end value, 512 the cheapest
const float shadowDistance = 96.0; // [64 96 128 160] Distance in blocks the shadow pass covers. Lower is much cheaper
const float shadowIntervalSize = 7.0; // [1.0 3.0 5.0 7.0 9.0 11.0] Shadow interval. Higher values soften the banding of low resolution shadows
const float entityShadowDistanceMul = 0.25; // [0.125 0.25 0.5 1.0] How far away entities still cast shadows, as a fraction of the shadow distance. Lower is much cheaper
#define SHADOW_STRENGTH 0.75 // [0.25 0.5 0.75 1.0] How strongly shadows darken the world

/* ------------------------------------------------------------------ *
 *  LIGHT AND COLOUR
 * ------------------------------------------------------------------ */

#define EXPOSURE 1.0 // [0.85 0.9 0.95 1.0 1.05 1.1 1.15] Overall brightness
#define SATURATION 1.08 // [0.9 0.95 1.0 1.05 1.08 1.12 1.2] Colour saturation
#define CONTRAST 1.05 // [0.95 1.0 1.05 1.1 1.15] Contrast around mid grey
#define SUNSET_STRENGTH 1.0 // [0.5 0.75 1.0 1.25 1.5] Warmth of sunrise and sunset
#define NIGHT_BRIGHTNESS 1.0 // [0.8 0.9 1.0 1.1 1.2] Night time light level
#define COLOR_WARMTH 0.5 // [0.0 0.25 0.5 0.75 1.0] Colour balance: 0 is cool and blue, 0.5 neutral, 1 warm and golden

/* ------------------------------------------------------------------ *
 *  ATMOSPHERE
 * ------------------------------------------------------------------ */

#define FOG_DENSITY 1.0 // [0.6 0.8 1.0 1.2 1.4] Distance fog density
const float ambientOcclusionLevel = 0.30; // [0.0 0.2 0.3 0.4 0.6 0.8] Vanilla ambient occlusion floor. Lower makes corners darker, higher makes them flatter
#define CLOUD_SHADING // Grade the clouds by time of day: white by day, blue-grey at night, warm at the horizon
#define SUN_GLARE // Warm glare around the sun's screen position, over clean sky only

/* ------------------------------------------------------------------ *
 *  WATER
 *  The reflection is an analytic sky colour, not a screen-space or
 *  planar reflection: it costs arithmetic only, never a texture fetch.
 * ------------------------------------------------------------------ */

#define WATER_REFLECTIONS // Sky colour reflected on water surfaces, weighted by view angle
#define WATER_REFLECTION_STRENGTH 0.15 // [0.0 0.15 0.3 0.5 0.7] Reflection strength
#define WATER_DEPTH // Water gets its colour and opacity from how deep it is, plus a shoreline rim
//#define WATER_WAVES // Animated shimmer on the reflected direction (adds 4 sin/cos per water pixel)

/* ------------------------------------------------------------------ *
 *  VEGETATION AND WATER MOTION
 *  Vertex stage only. A couple of sine calls per vertex and no per-pixel
 *  cost at all, which is why this is on even in the fastest preset.
 * ------------------------------------------------------------------ */

#define WAVING_PLANTS // Grass, flowers, crops and leaves sway in the wind
#define WAVING_WATER // The water surface moves up and down slightly
#define WAVE_STRENGTH 1.0 // [0.5 1.0 1.5 2.0] How far vegetation and water travel
#define VEGETATION_POLISH // Grass and leaves get richer colour and a little extra light, as if the sun went through them

/* ------------------------------------------------------------------ *
 *  UNDERWATER
 * ------------------------------------------------------------------ */

#define UNDERWATER_CAUSTICS // Animated light ripples on everything while the camera is submerged
#define HANDHELD_LIGHT // A torch or lantern in your hand lights the ground around you
#define DIMENSION_TUNING // Warm the light and thicken the fog in the Nether, cool it in the End

/* ------------------------------------------------------------------ *
 *  PERFORMANCE
 *  The one switch that can remove a whole full-screen pass. With this
 *  off, composite.fsh is not run at all: no fog, no grade, no underwater
 *  tint, and the world is shown exactly as the gbuffers programs wrote
 *  it. Terrain lighting, sky and water still look better than vanilla.
 * ------------------------------------------------------------------ */

#define POST_PROCESSING // Full-screen post pass: distance fog, colour grade, underwater tint

/* ------------------------------------------------------------------ *
 *  POST PROCESSING
 *  All three are off by default: each one costs either extra texture
 *  fetches or extra arithmetic on every pixel of the screen.
 * ------------------------------------------------------------------ */

//#define BLOOM // Bright pass glow. Four extra fetches of the scene buffer, wide and cheap
//#define VIGNETTE // Darkened screen corners
//#define SSAO // Depth-only contact shadows. Four extra depth fetches and five depth linearisations

#endif
