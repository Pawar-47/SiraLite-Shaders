/*
    SiraLite Shaders - shadow lookups.

    Only compiled when SHADOW_QUALITY > 0. The sampler declaration is inside
    the same #if on purpose: Iris decides whether to render the shadow pass by
    checking whether any program uses a shadow buffer, so with shadows off no
    program references one and the pass is skipped entirely.

    shadowtex1 is used instead of shadowtex0 because shadowtex1 holds opaque
    geometry only, so water and glass never cast solid shadows.
*/

#ifndef SIRALITE_SHADOW_GLSL
#define SIRALITE_SHADOW_GLSL

#include "/lib/common.glsl"

#if SHADOW_QUALITY > 0

uniform sampler2D shadowtex1;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

/* One constant depth bias in shadow clip space. Kept simple and branch free
   apart from the frustum test; derivative based bias is not worth the
   undefined derivative behaviour inside a divergent branch. */
#define SIRALITE_SHADOW_BIAS 0.0012

/* 1.0 = lit, 0.0 = fully shadowed. */
float getShadow(vec3 viewPos) {
	vec4 playerPos = gbufferModelViewInverse * vec4(viewPos, 1.0);
	vec4 clip = shadowProjection * (shadowModelView * playerPos);

	vec3 screen = clip.xyz / clip.w;
	screen = screen * 0.5 + 0.5;

	// Outside the shadow frustum: treat as lit rather than as black.
	if (clip.w <= 0.0 || screen.x < 0.0 || screen.x > 1.0 ||
	    screen.y < 0.0 || screen.y > 1.0 || screen.z > 1.0) {
		return 1.0;
	}

	float z = screen.z - SIRALITE_SHADOW_BIAS;

#if SHADOW_QUALITY > 1
	vec2 texel = vec2(0.5 / float(shadowMapResolution));
	float s;
	s  = step(z, texture(shadowtex1, screen.xy + vec2(-texel.x, -texel.y)).r);
	s += step(z, texture(shadowtex1, screen.xy + vec2( texel.x, -texel.y)).r);
	s += step(z, texture(shadowtex1, screen.xy + vec2(-texel.x,  texel.y)).r);
	s += step(z, texture(shadowtex1, screen.xy + vec2( texel.x,  texel.y)).r);
	return s * 0.25;
#else
	return step(z, texture(shadowtex1, screen.xy).r);
#endif
}

#endif

#endif
