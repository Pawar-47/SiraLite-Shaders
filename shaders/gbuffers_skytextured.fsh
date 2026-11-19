#version 330 compatibility

uniform sampler2D gtexture;
uniform float alphaTestRef = 0.1;

in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

/* Sun and moon quads. Slightly lifted so they still read as light sources
   next to the glow in gbuffers_skybasic. */
void main() {
	vec4 albedo = texture(gtexture, texcoord) * glcolor;

	if (albedo.a < alphaTestRef) {
		discard;
	}

	albedo.rgb *= 1.12;
	color = albedo;
}
