#version 330 compatibility

#include "/lib/lighting.glsl"

uniform sampler2D gtexture;
uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 viewPos;
in vec3 normalView;
in float isWater;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

/*
    Translucent terrain: water, ice and glass. Only water gets the surface
    treatment now, because shaders/block.properties tells us which block this
    is. The reflection is an analytic sky colour weighted by view angle and the
    highlight is the sun's own direction, so together they cost arithmetic only
    and never a texture fetch or a second pass.
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

	reflected = normalize(reflected);

	// Sky reflected at grazing angles, weighted out entirely on glass.
	lit = mix(lit, skyGradient(reflected), fres * WATER_REFLECTION_STRENGTH * isWater);

	// Sun glint: cos^32 through five squarings, no pow().
	float glint = max(dot(reflected, normalize(sunPosition)), 0.0);
	glint *= glint;
	glint *= glint;
	glint *= glint;
	glint *= glint;
	glint *= glint;
	lit += vec3(1.0, 0.92, 0.78) * glint * 0.9 * isWater * daylightAmount();
#endif

	color = vec4(lit, albedo.a);
}
