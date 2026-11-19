#version 330 compatibility

#include "/lib/common.glsl"

uniform sampler2D gtexture;
uniform float alphaTestRef = 0.1;

in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

/*
    Vanilla draws the cloud geometry; this only grades its colour, which is the
    difference between clouds and grey blobs. White by day, blue-grey at night,
    and warm from underneath at sunrise and sunset, where vanilla leaves them
    the same pale beige all day.
*/
void main() {
	vec4 albedo = texture(gtexture, texcoord) * glcolor;

	if (albedo.a < alphaTestRef) {
		discard;
	}

#ifdef CLOUD_SHADING
	float day = daylightAmount();
	float horizon = clamp(horizonAmount() * SUNSET_STRENGTH, 0.0, 1.0);

	vec3 tint = mix(vec3(0.46, 0.55, 0.76), vec3(1.07, 1.06, 1.03), day);
	tint = mix(tint, vec3(1.24, 0.78, 0.55), horizon * 0.9);

	albedo.rgb *= tint;
#endif

	color = albedo;
}
