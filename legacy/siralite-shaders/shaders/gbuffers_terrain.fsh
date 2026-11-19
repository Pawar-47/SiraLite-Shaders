#version 330 compatibility

#include "/lib/lighting.glsl"

uniform sampler2D gtexture;
uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 viewPos;
in vec3 normalView;
in float vegMask;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

/* Terrain is the overwhelming majority of the pixels on screen, so this is the
   cheapest path in the pack: one texture fetch, one lightmap fetch, arithmetic. */
void main() {
	vec4 albedo = texture(gtexture, texcoord) * glcolor;

	if (albedo.a < alphaTestRef) {
		discard;
	}

	vec3 lit = shadeLit(albedo.rgb, lmcoord, viewPos, normalView);

#ifdef VEGETATION_POLISH
	/* Leaves and grass are thin, and sunlight goes through them, so they read
	   richer and lighter than the solid block next to them. Branchless: vegMask
	   is 0 on everything that is not vegetation. */
	float grey = luma(lit);
	lit = mix(lit, mix(vec3(grey), lit, 1.22) * 1.06, vegMask);
#endif

	color = vec4(lit, albedo.a);
}
