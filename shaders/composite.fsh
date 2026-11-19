#version 330 compatibility

#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform int isEyeInWater;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

/*
    The only post processing pass in the pack. Everything that happens after
    the world is drawn happens here, once, so there is one scene fetch, one
    depth fetch and then arithmetic. The optional effects add their own fetches
    and are off by default.
*/
void main() {
	vec3 scene = texture(colortex0, texcoord).rgb;
	float depth = texture(depthtex0, texcoord).r;

	// depth == 1.0 means nothing was drawn there: sky, sun, moon, stars.
	if (depth < 1.0) {
		float dist = linearizeDepth(depth);

		float start = far * 0.45 / FOG_DENSITY;
		float end = far * 0.98 / FOG_DENSITY;
		float fog = clamp((dist - start) / max(end - start, 1.0), 0.0, 1.0);

		float horizon = clamp(horizonAmount() * SUNSET_STRENGTH, 0.0, 1.0);
		vec3 fogCol = mix(fogColor, fogColor * vec3(1.20, 0.95, 0.82), horizon * 0.6);
		float fogAmount = fog * fog * (3.0 - 2.0 * fog);

		if (isEyeInWater == 1) {
			// Water: dense blue-green fog and a colour shift instead of the
			// surface fog.
			fogAmount = clamp(dist / max(far * 0.35, 8.0), 0.0, 1.0) * 0.92;
			fogCol = vec3(0.055, 0.19, 0.30) * (0.55 + 0.45 * daylightAmount());
		}

		scene = mix(scene, fogCol, fogAmount);

#ifdef SSAO
		/* Depth only contact shadow: a neighbour closer than this pixel means
		   this pixel sits in a groove. Four taps, no random rotation, no
		   noise, no geometry sampling. */
		vec2 px = vec2(1.0 / viewWidth, 1.0 / viewHeight) * 3.0;
		float occ = 0.0;
		occ += max(0.0, dist - linearizeDepth(texture(depthtex0, texcoord + vec2(px.x, 0.0)).r));
		occ += max(0.0, dist - linearizeDepth(texture(depthtex0, texcoord - vec2(px.x, 0.0)).r));
		occ += max(0.0, dist - linearizeDepth(texture(depthtex0, texcoord + vec2(0.0, px.y)).r));
		occ += max(0.0, dist - linearizeDepth(texture(depthtex0, texcoord - vec2(0.0, px.y)).r));
		occ *= 0.25;
		scene *= 1.0 - clamp(occ * 0.55, 0.0, 1.0) * 0.7;
#endif
	}

#ifdef BLOOM
	{
		// Four widely spaced taps of the already drawn scene. Cheap, wide and
		// soft; not a multi-pass bloom and not trying to be one.
		vec2 px = vec2(1.0 / viewWidth, 1.0 / viewHeight) * 4.0;
		vec3 bright = max(texture(colortex0, texcoord + vec2(px.x, 0.0)).rgb - 0.78, 0.0);
		bright += max(texture(colortex0, texcoord - vec2(px.x, 0.0)).rgb - 0.78, 0.0);
		bright += max(texture(colortex0, texcoord + vec2(0.0, px.y)).rgb - 0.78, 0.0);
		bright += max(texture(colortex0, texcoord - vec2(0.0, px.y)).rgb - 0.78, 0.0);
		scene += bright * 0.3;
	}
#endif

	scene = gradeColor(scene);

#ifdef VIGNETTE
	{
		vec2 v = texcoord - 0.5;
		scene *= 1.0 - dot(v, v) * 0.6;
	}
#endif

	color = vec4(clamp(scene, 0.0, 1.0), 1.0);
}
