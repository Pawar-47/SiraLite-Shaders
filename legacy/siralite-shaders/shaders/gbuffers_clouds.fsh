#version 330 compatibility

#include "/lib/common.glsl"

uniform sampler2D gtexture;
uniform float alphaTestRef = 0.1;

in vec2 texcoord;
in vec4 glcolor;
in vec3 viewPos;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

/*
    Vanilla draws the cloud geometry; this grades its colour and places it in
    the air. Three things do the work: a time of day tint, a pull toward the
    horizon colour so clouds belong to the sky instead of looking pasted on it,
    and a silver lining where the cloud faces the sun or moon.
*/
void main() {
	vec4 albedo = texture(gtexture, texcoord) * glcolor;

	if (albedo.a < alphaTestRef) {
		discard;
	}

#ifdef CLOUD_SHADING
	float day = daylightAmount();
	float horizon = clamp(horizonAmount() * SUNSET_STRENGTH, 0.0, 1.0);

	// White by day, blue-grey at night, warm from underneath at the horizon.
	vec3 tint = mix(vec3(0.46, 0.55, 0.76), vec3(1.07, 1.06, 1.03), day);
	tint = mix(tint, vec3(1.24, 0.78, 0.55), horizon * 0.9);
	albedo.rgb *= tint;

	// Haze: clouds are seen through the atmosphere, so they take its colour.
	albedo.rgb = mix(albedo.rgb, fogColor, 0.35);

	// Silver lining, strongest when the sun is low.
	vec3 dir = normalize(viewPos);
	float towardSun = max(dot(dir, normalize(sunPosition)), 0.0);
	towardSun *= towardSun;
	albedo.rgb += vec3(1.0, 0.86, 0.66) * towardSun *
	              (0.10 + 0.30 * horizon + 0.06 * day);

	/* Vanilla clouds are flat slabs at y=192, so the only shape a shader can
	   read is where a fragment sits inside the slab: the top catches the sky,
	   the base sits in the shadow of the cloud above it. This is what makes
	   blocky clouds read as thick without any volumetric work. */
	vec3 worldPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	float height = worldPos.y + cameraPosition.y;
	float layerHeight = clamp((height - 191.85) * 0.25, 0.0, 1.0);
	albedo.rgb *= 0.72 + 0.55 * layerHeight;

	// And a distance fade, so the cloud layer does not end in a hard line.
	albedo.a *= clamp((320.0 - length(worldPos.xz)) * 0.01, 0.0, 1.0);
#endif

	color = albedo;
}
