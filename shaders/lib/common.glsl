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
uniform float near;
uniform float far;

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
	float day = daylightAmount();
	float horizon = clamp(horizonAmount() * SUNSET_STRENGTH, 0.0, 1.0);

	float t = clamp(dot(dir, up), 0.0, 1.0);
	t = sqrt(t); // wider gradient near the horizon, no pow()

	vec3 col = mix(fogColor, skyColor, t);

	// Warm band hugging the horizon at sunrise and sunset.
	col = mix(col, fogColor * vec3(1.18, 0.94, 0.80), horizon * 0.5 * (1.0 - t));

	// Sun glow, cos^8 through three multiplies.
	vec3 sunDir = normalize(sunPosition);
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
