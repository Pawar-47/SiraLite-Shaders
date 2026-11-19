#version 330 compatibility

out vec2 texcoord;
out vec4 glcolor;
out vec3 viewPos;

void main() {
	vec4 viewPosition = gl_ModelViewMatrix * gl_Vertex;
	gl_Position = gl_ProjectionMatrix * viewPosition;
	viewPos = viewPosition.xyz;

	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
}
