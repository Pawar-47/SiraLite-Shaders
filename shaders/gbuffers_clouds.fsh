#version 330 compatibility

uniform sampler2D gtexture;
uniform float alphaTestRef = 0.1;

in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

/* Vanilla clouds, untouched. Vanilla already shades them by time of day and
   they cost one fetch each; replacing them would cost far more than it could
   ever add on this hardware. */
void main() {
	vec4 albedo = texture(gtexture, texcoord) * glcolor;

	if (albedo.a < alphaTestRef) {
		discard;
	}

	color = albedo;
}
