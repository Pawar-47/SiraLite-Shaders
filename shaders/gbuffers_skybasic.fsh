#version 330 compatibility

#include "/lib/common.glsl"

uniform int renderStage;

in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

vec3 screenToView(vec3 screenPos) {
	vec4 ndcPos = vec4(screenPos, 1.0) * 2.0 - 1.0;
	vec4 tmp = gbufferProjectionInverse * ndcPos;
	return tmp.xyz / tmp.w;
}

/*
    The sky is one analytic gradient: no texture, no noise, no atmosphere
    simulation. Colours come from vanilla's own skyColor and fogColor, so biome
    tint, rain, thunder and the day cycle all keep working for free. On top of
    that sits an optional band of high cirrus, which is what makes sunrise and
    sunset read as a sky rather than as a colour ramp.
*/
void main() {
	if (renderStage == MC_RENDER_STAGE_STARS) {
		color = glcolor;
		return;
	}

	vec3 dir = normalize(screenToView(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0)));
	vec3 sky = skyGradient(dir);

#ifdef SKY_CIRRUS
	float cirrus = cirrusDensity(dir);

	vec3 cirrusTint = mix(vec3(0.52, 0.60, 0.80), vec3(1.05, 1.04, 1.02), daylightAmount());
	cirrusTint = mix(cirrusTint, vec3(1.28, 0.80, 0.56),
	                 clamp(horizonAmount() * SUNSET_STRENGTH, 0.0, 1.0) * 0.85);

	sky = mix(sky, cirrusTint, cirrus * 0.55 * overworldAmount());
#endif

	color = vec4(sky, 1.0);
}
