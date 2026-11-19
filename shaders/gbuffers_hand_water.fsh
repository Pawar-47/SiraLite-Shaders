#version 330 compatibility

#include "/lib/lighting.glsl"

uniform sampler2D gtexture;
uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 viewPos;
in vec3 normalView;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

/* Translucent parts of the held item. Nothing to reflect here, so this is the
   plain lit path. */
void main() {
	vec4 albedo = texture(gtexture, texcoord) * glcolor;

	if (albedo.a < alphaTestRef) {
		discard;
	}

	color = vec4(shadeLit(albedo.rgb, lmcoord, viewPos, normalView), albedo.a);
}
