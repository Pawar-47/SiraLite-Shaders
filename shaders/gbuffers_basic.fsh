#version 330 compatibility

#include "/lib/lighting.glsl"

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec4 glcolor;
in vec3 viewPos;
in vec3 normalView;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

/* Untextured geometry: selection outlines, leashes, hitboxes and similar.
   One lightmap fetch, arithmetic only. */
void main() {
	vec4 albedo = glcolor;

	if (albedo.a < alphaTestRef) {
		discard;
	}

	color = vec4(albedo.rgb * lightmapLight(lmcoord), albedo.a);
}
