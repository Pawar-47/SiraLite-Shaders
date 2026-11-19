#version 330 compatibility

#include "/lib/common.glsl"

out vec2 texcoord;
out vec3 sunScreen; // xy = screen position of the sun, z = 1 when it is in front of the camera

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	// Project the sun once per vertex instead of once per pixel.
	vec4 clip = gbufferProjection * vec4(normalize(sunPosition) * 100.0, 1.0);
	vec2 ndc = clip.xy / max(abs(clip.w), 1e-4);
	sunScreen = vec3(ndc * 0.5 + 0.5, step(1e-4, clip.w));
}
