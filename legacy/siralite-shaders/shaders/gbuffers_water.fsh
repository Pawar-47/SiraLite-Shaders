#version 330 compatibility

#include "/lib/lighting.glsl"

uniform sampler2D gtexture;
uniform float alphaTestRef = 0.1;

#ifdef WATER_DEPTH
/* Opaque scene depth, snapshotted by Iris before translucents are drawn, so
   this is the depth of whatever is behind the water. It is the separate copy,
   not the depth attachment this pass writes to. */
uniform sampler2D depthtex1;
#endif

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
    treatment, because shaders/block.properties tells us which block this is.
    The reflection is an analytic sky colour weighted by view angle, the
    highlight is the sun's own direction, and the depth comes from Iris's
    pre-translucents depth copy: together they cost one depth fetch and
    arithmetic, never a reflection pass.
*/
void main() {
	vec4 albedo = texture(gtexture, texcoord) * glcolor;

	if (albedo.a < alphaTestRef) {
		discard;
	}

	vec3 lit = shadeLit(albedo.rgb, lmcoord, viewPos, normalView);
	float outAlpha = albedo.a;

#ifdef WATER_DEPTH
	/* The gap between the water surface and the opaque geometry behind it is
	   the water's thickness. Shallow water stays clear and bright, deep water
	   turns blue and hides what is under it, and the last half block before a
	   shore gets a rim of light. */
	float surfaceDepth = linearizeDepth(gl_FragCoord.z);
	float behindDepth = linearizeDepth(texture(depthtex1, gl_FragCoord.xy / vec2(viewWidth, viewHeight)).r);
	float thickness = clamp(behindDepth - surfaceDepth, 0.0, 64.0);
	float depthAmount = thickness / (thickness + 3.0);

	lit = mix(lit, lit * vec3(0.42, 0.72, 1.02), depthAmount * 0.85 * isWater);

	float shore = (1.0 - smoothstep(0.0, 0.55, thickness)) * isWater;
	lit += vec3(0.85, 0.95, 1.0) * shore * 0.12;

	outAlpha = mix(outAlpha, max(outAlpha, 0.85), depthAmount * 0.75 * isWater);
#endif

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

	color = vec4(lit, outAlpha);
}
