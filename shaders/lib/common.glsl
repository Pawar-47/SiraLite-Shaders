/*
    SiraLite Shaders - shared uniforms and small helpers.

    Everything here is either a uniform Iris binds for every program or a
    function built from cheap arithmetic. No texture fetches, no loops.
*/

#ifndef SIRALITE_COMMON_GLSL
#define SIRALITE_COMMON_GLSL

#include "/lib/settings.glsl"

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

uniform vec3 cameraPosition;
uniform vec3 sunPosition; // view space, length 100
uniform vec3 moonPosition; // view space, length 100
uniform vec3 upPosition; // world "up", rotated into view space, length 100
uniform vec3 skyColor;
uniform vec3 fogColor;

uniform float viewWidth;
uniform float viewHeight;
uniform float frameTimeCounter;
uniform float rainStrength;
uniform int isEyeInWater;
uniform int heldBlockLightValue;
uniform bool hasSkylight;
uniform bool hasCeiling;
uniform float near;
uniform float far;

/* Which dimension is this? Iris answers directly: the Nether has a ceiling and
   no sky light, the End has no sky light and no ceiling. Booleans, so each
   helper is two comparisons and no texture work. */
float netherAmount() {
	return (!hasSkylight && hasCeiling) ? 1.0 : 0.0;
}

float endAmount() {
	return (!hasSkylight && !hasCeiling) ? 1.0 : 0.0;
}

float overworldAmount() {
	return hasSkylight ? 1.0 : 0.0;
}

float luma(vec3 c) {
	return dot(c, vec3(0.2125, 0.7154, 0.0721));
}

/* Sun elevation: -1 when straight below, +1 at zenith. Both vectors are in
   view space, so the dot product is independent of where the camera looks. */
float sunElevation() {
	return dot(normalize(sunPosition), normalize(upPosition));
}

/* 0 at night, 1 in full daylight, smooth across dawn and dusk. */
float daylightAmount() {
	return smoothstep(-0.12, 0.20, sunElevation());
}

/* 1 when the sun is at the horizon, 0 when it is high up or well below.
   Edges are ascending on purpose: smoothstep with edge0 >= edge1 is
   undefined in GLSL. */
float horizonAmount() {
	return 1.0 - smoothstep(0.02, 0.30, abs(sunElevation()));
}

/* Analytic sky. Used by the sky program, the water reflection and the fog
   colour. Two dot products, no fetches, no noise. */
vec3 skyGradient(vec3 dir) {
	vec3 up = normalize(upPosition);
	vec3 sunDir = normalize(sunPosition);
	float day = daylightAmount();
	float horizon = clamp(horizonAmount() * SUNSET_STRENGTH, 0.0, 1.0);

	float t = clamp(dot(dir, up), 0.0, 1.0);
	t = sqrt(t); // wider gradient near the horizon, no pow()

	vec3 col = mix(fogColor, skyColor, t);

	/* Warm band at sunrise and sunset, weighted by azimuth so it gathers on
	   the sun's side of the sky. Without the azimuth term the whole horizon
	   turns orange, which is the giveaway of a cheap sky. */
	vec2 flatDir = dir.xz;
	vec2 flatSun = sunDir.xz;
	float azim = dot(flatDir, flatSun) *
	             inversesqrt(max(dot(flatDir, flatDir) * dot(flatSun, flatSun), 1e-4));
	col = mix(col, fogColor * vec3(1.24, 0.92, 0.76),
	          horizon * 0.6 * (1.0 - t) * (0.2 + 0.8 * clamp(azim, 0.0, 1.0)));

	// Sun glow, cos^8 through three multiplies.
	float sun = max(dot(dir, sunDir), 0.0);
	sun *= sun;
	sun *= sun;
	sun *= sun;
	col += vec3(1.00, 0.70, 0.40) * sun * (0.35 + 0.65 * horizon);

	// Weak cool moon glow so the night sky is not a flat sheet of navy.
	vec3 moonDir = normalize(moonPosition);
	float moon = max(dot(dir, moonDir), 0.0);
	moon *= moon;
	moon *= moon;
	moon *= moon;
	col += vec3(0.55, 0.68, 0.95) * moon * 0.10 * (1.0 - day);

	return max(col, vec3(0.0));
}

/* Thin high cloud, for the sky program only. The ray is projected onto a fixed
   altitude so the pattern slides past as you move, and the two-tone stretch
   reads as streaks rather than blobs. No texture, no hash, four sine calls. */
float cirrusDensity(vec3 dir) {
	if (dir.y < 0.06) {
		return 0.0;
	}

	vec2 p = clamp(dir.xz / dir.y, vec2(-40.0), vec2(40.0)) * vec2(0.5, 1.5);
	p += vec2(frameTimeCounter * 0.004, frameTimeCounter * 0.0015);

	float n = sin(p.x * 1.3 + sin(p.y * 2.1)) + sin(p.y * 0.8 - sin(p.x * 1.7) * 0.8);
	float density = smoothstep(0.6, 1.3, n);

	// Fade out at the horizon, where the pattern would alias into noise.
	return density * smoothstep(0.06, 0.30, dir.y);
}

/* Colour grade, done in gamma space on purpose: staying in the buffer's own
   space saves three pow() calls per pixel, which is real time on integrated
   graphics. The buffer is 8 bit, so there is no HDR range to lose. */
vec3 gradeColor(vec3 c) {
	c *= EXPOSURE;

	float l = luma(c);
	c = mix(vec3(l), c, SATURATION);
	c = mix(c, c * c * (3.0 - 2.0 * c), 0.18); // gentle filmic S-curve
	c = mix(vec3(0.5), c, CONTRAST);

	// Warm highlights, cool shadows.
	c *= mix(vec3(0.975, 0.99, 1.03), vec3(1.03, 1.005, 0.975), clamp(l * 1.4, 0.0, 1.0));

	return clamp(c, 0.0, 1.0);
}

/* Perspective depth buffer value to view space distance in blocks. */
float linearizeDepth(float depth) {
	float z = depth * 2.0 - 1.0;
	return (2.0 * near * far) / (far + near - z * (far - near));
}

#endif
