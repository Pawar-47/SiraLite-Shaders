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

/* Sun by day, moon by night, on top of vanilla's own face shading. Exactly
   neutral (vec3(1.0)) when normalView is zero, which is what programs without
   usable normals pass in. */
vec3 sunFacing(vec3 normalView) {
	float day = daylightAmount();
	float d = dot(normalView, normalize(sunPosition));
	float m = dot(normalView, normalize(moonPosition));

	float sunTerm = (max(d, 0.0) * 0.18 - max(-d, 0.0) * 0.07) * day;
	float moonTerm = max(m, 0.0) * 0.10 * (1.0 - day);

	return vec3(1.0 + sunTerm + moonTerm);
}

/* The lighting every opaque, lit program uses. */
vec3 shadeLit(vec3 albedo, vec2 lmcoord, vec3 viewPos, vec3 normalView) {
	vec3 light = lightmapLight(lmcoord);
	light *= sunFacing(normalView);

	/* Light that arrives without the sun is sky light, and sky light is blue.
	   Shadowed ground therefore keeps a cold ambient instead of going black,
	   which is what makes shadows look like shade rather than holes. */
	const vec3 shadeTint = vec3(0.34, 0.42, 0.60);

#if SHADOW_QUALITY > 0
	// Only where sky light reaches, so interiors and caves are left alone.
	float skyMask = smoothstep(0.05, 0.6, lmcoord.y);
	float shadow = getShadow(viewPos);

	// Fade shadows out at the edge of the shadow frustum. A hard line where
	// shadows stop looks worse than having no shadows at all.
	float fade = smoothstep(shadowDistance * 0.82, shadowDistance, length(viewPos));
	shadow = mix(shadow, 1.0, fade);

	light *= mix(vec3(1.0), mix(shadeTint, vec3(1.0), shadow), SHADOW_STRENGTH * skyMask);
#endif

#ifdef UNDERWATER_CAUSTICS
	/* isEyeInWater is a uniform, so this branch is taken by every invocation
	   at once: it costs nothing above water and a couple of sines below it. */
	if (isEyeInWater == 1) {
		vec3 worldPos = cameraPosition + mat3(gbufferModelViewInverse) * viewPos;
		float t = frameTimeCounter * 1.6;
		float ripple = sin(worldPos.x * 1.9 + t) * sin(worldPos.z * 2.1 - t * 0.8);
		light *= 1.0 + 0.22 * ripple;
	}
#endif

	return albedo * light;
}

#endif
