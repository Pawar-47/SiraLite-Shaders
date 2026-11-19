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
    tint, rain, thunder and the day cycle all keep working for free.
*/
void main() {
	if (renderStage == MC_RENDER_STAGE_STARS) {
		color = glcolor;
	} else {
		vec3 pos = screenToView(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0));
		color = vec4(skyGradient(normalize(pos)), 1.0);
	}
}
