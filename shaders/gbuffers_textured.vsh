#version 330 compatibility

out vec2 texcoord;
out vec2 lmcoord;
out vec4 glcolor;
out vec3 viewPos;
out vec3 normalView;

void main() {
	vec4 viewPosition = gl_ModelViewMatrix * gl_Vertex;
	gl_Position = gl_ProjectionMatrix * viewPosition;
	viewPos = viewPosition.xyz;

	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	vec3 n = gl_NormalMatrix * gl_Normal;
	float len = length(n);
	normalView = (len > 1e-5) ? (n / len) : vec3(0.0);
}
