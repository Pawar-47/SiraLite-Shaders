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
#define SHADOW_STRENGTH 0.75 // [0.25 0.5 0.75 1.0] How strongly shadows darken the world

/* ------------------------------------------------------------------ *
 *  LIGHT AND COLOUR
 * ------------------------------------------------------------------ */

#define EXPOSURE 1.0 // [0.85 0.9 0.95 1.0 1.05 1.1 1.15] Overall brightness
#define SATURATION 1.08 // [0.9 0.95 1.0 1.05 1.08 1.12 1.2] Colour saturation
#define CONTRAST 1.05 // [0.95 1.0 1.05 1.1 1.15] Contrast around mid grey
#define SUNSET_STRENGTH 1.0 // [0.5 0.75 1.0 1.25 1.5] Warmth of sunrise and sunset
#define NIGHT_BRIGHTNESS 1.0 // [0.8 0.9 1.0 1.1 1.2] Night time light level

/* ------------------------------------------------------------------ *
 *  ATMOSPHERE
 * ------------------------------------------------------------------ */

#define FOG_DENSITY 1.0 // [0.6 0.8 1.0 1.2 1.4] Distance fog density

/* ------------------------------------------------------------------ *
 *  WATER
 *  The reflection is an analytic sky colour, not a screen-space or
 *  planar reflection: it costs arithmetic only, never a texture fetch.
 * ------------------------------------------------------------------ */

#define WATER_REFLECTIONS // Sky colour reflected on water surfaces, weighted by view angle
#define WATER_REFLECTION_STRENGTH 0.15 // [0.0 0.15 0.3 0.5 0.7] Reflection strength
//#define WATER_WAVES // Animated shimmer on the reflected direction (adds 4 sin/cos per water pixel)

/* ------------------------------------------------------------------ *
 *  POST PROCESSING
 *  All three are off by default: each one costs either extra texture
 *  fetches or extra arithmetic on every pixel of the screen.
 * ------------------------------------------------------------------ */

//#define BLOOM // Bright pass glow. Four extra fetches of the scene buffer, wide and cheap
//#define VIGNETTE // Darkened screen corners
//#define SSAO // Depth-only contact shadows. Four extra depth fetches and five depth linearisations

#endif
