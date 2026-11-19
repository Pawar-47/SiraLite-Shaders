#version 330 compatibility

#include "/lib/waving.glsl"

in vec4 mc_Entity; // block id from shaders/block.properties

out vec2 texcoord;
out vec2 lmcoord;
out vec4 glcolor;
out vec3 viewPos;
out vec3 normalView;

void main() {
	// Vegetation sways here, per vertex. Blocks with no id are untouched.
	vec3 modelPos = waveVegetation(gl_Vertex.xyz, mc_Entity.x);

	vec4 viewPosition = gl_ModelViewMatrix * vec4(modelPos, 1.0);
	gl_Position = gl_ProjectionMatrix * viewPosition;
	viewPos = viewPosition.xyz;

	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	vec3 n = gl_NormalMatrix * gl_Normal;
	float len = length(n);
	normalView = (len > 1e-5) ? (n / len) : vec3(0.0);
}
