/*
    SiraLite Shaders - lighting model.

    One lightmap fetch per pixel, then arithmetic only. The lightmap is vanilla's
    own brightness curve, which already encodes smooth lighting, ambient
    occlusion and the block/sky light mix; we keep that curve and only tint it,
    so caves stay dark and torch lit rooms stay readable.
*/

#ifndef SIRALITE_LIGHTING_GLSL
#define SIRALITE_LIGHTING_GLSL

#include "/lib/common.glsl"
#include "/lib/shadow.glsl"

uniform sampler2D lightmap;

/* Tinted lightmap value for a fragment.
   lmcoord.x is block light (torch), lmcoord.y is sky light. */
vec3 lightmapLight(vec2 lmcoord) {
	vec3 raw = texture(lightmap, lmcoord).rgb;

	float block = clamp(lmcoord.x, 0.0, 1.0);
	float sky = clamp(lmcoord.y, 0.0, 1.0);
	float b2 = block * block;
	float s2 = sky * sky;

	float day = daylightAmount();
	float horizon = clamp(horizonAmount() * SUNSET_STRENGTH, 0.0, 1.0);

	vec3 torch = vec3(1.14, 0.82, 0.55);
	vec3 dayTint = mix(vec3(1.0, 1.0, 1.02), vec3(1.10, 0.93, 0.79), horizon);
	vec3 nightTint = vec3(0.64, 0.76, 1.06) * clamp(NIGHT_BRIGHTNESS, 0.05, 4.0);
	vec3 skyTint = mix(nightTint, dayTint, day);

	/* Convex blend of both light sources that falls back to neutral when
	   neither contributes: dimension ambient light, the End, unlit caves.
	   No division, so no division by zero and no NaN. */
	float neutral = 1.0 - clamp(b2 + s2, 0.0, 1.0);
	vec3 tint = torch * b2 + skyTint * s2 + vec3(neutral);

	// Small lift around mid block light: caves read better, fully lit rooms
	// are untouched.
	tint *= 1.0 + 0.10 * (block - block * block) * 4.0;

	return raw * tint;
}

/* Sun and sky sides of a face. Exactly neutral (vec3(1.0)) when normalView is
   zero, which is what programs without usable normals pass in. */
vec3 sunFacing(vec3 normalView) {
	float day = daylightAmount();
	float d = dot(normalView, normalize(sunPosition));
	return vec3(1.0 + (max(d, 0.0) * 0.18 - max(-d, 0.0) * 0.07) * day);
}

/* The lighting every opaque, lit program uses. */
vec3 shadeLit(vec3 albedo, vec2 lmcoord, vec3 viewPos, vec3 normalView) {
	vec3 light = lightmapLight(lmcoord);
	light *= sunFacing(normalView);

#if SHADOW_QUALITY > 0
	// Only where sky light reaches, so interiors and caves are left alone.
	float skyMask = smoothstep(0.05, 0.6, lmcoord.y);
	light *= mix(1.0, getShadow(viewPos), SHADOW_STRENGTH * skyMask);
#endif

	return albedo * light;
}

#endif
