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

/*
    Translucent terrain: water, ice and glass. The reflection is the analytic
    sky colour, weighted by the angle between the view ray and the surface
    normal. There is no scene, planar or screen space reflection anywhere in
    this pack, so this costs arithmetic only.
*/
void main() {
	vec4 albedo = texture(gtexture, texcoord) * glcolor;

	if (albedo.a < alphaTestRef) {
		discard;
	}

	vec3 lit = shadeLit(albedo.rgb, lmcoord, viewPos, normalView);

#ifdef WATER_REFLECTIONS
	vec3 viewDir = normalize(viewPos);
	vec3 upView = gbufferModelView[1].xyz; // world up, in view space

	float facing = clamp(abs(dot(viewDir, upView)), 0.0, 1.0);

	// Fresnel without pow(): (1 - cos)^4, then scaled by the option.
	float fres = 1.0 - facing;
	fres *= fres;
	fres *= fres;

	vec3 reflected = reflect(viewDir, upView);

#ifdef WATER_WAVES
	vec3 worldPos = cameraPosition + mat3(gbufferModelViewInverse) * viewPos;
	float t = frameTimeCounter;
	float wx = sin(worldPos.x * 0.62 + t * 1.30) + sin(worldPos.z * 0.47 - t * 1.05);
	float wz = cos(worldPos.z * 0.58 - t * 1.15) + cos(worldPos.x * 0.51 + t * 0.95);
	reflected = normalize(reflected + vec3(wx, 0.0, wz) * 0.09);
#endif

	lit = mix(lit, skyGradient(normalize(reflected)), fres * WATER_REFLECTION_STRENGTH);
#endif

	color = vec4(lit, albedo.a);
}
