#version 330 compatibility

uniform sampler2D gtexture;
uniform float alphaTestRef = 0.1;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

/* Only depth matters here. The discard keeps leaves, plants and grass from
   casting solid shadows, which is the one thing the shadow pass must do
   correctly for the result to look right. */
void main() {
	if (texture(gtexture, texcoord).a < alphaTestRef) {
		discard;
	}
	color = vec4(1.0);
}
