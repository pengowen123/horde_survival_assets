#version 150 core

// TODO: Implement anti-aliasing resolve (it affects all othe graphics components, so wait until
//		 those are complete first)

in vec2 v_Uv;

uniform sampler2D t_Screen;

out vec4 Target0;

const float offset = 1.0 / 300.0;

void main() {
	#if POSTPROCESSING_ENABLED == 1
	vec2 offsets[9] = vec2[](
		vec2(-offset,  offset),
		vec2( 0.0,	   offset),
		vec2( offset,  offset),
		vec2(-offset,  0.0),
		vec2( 0.0,	   0.0),
		vec2( offset,  0.0),
		vec2(-offset, -offset),
		vec2( 0.0,	  -offset),
		vec2( offset, -offset)
	);

	float kernel[9] = float[](
		0.0, 0.0, 0.0,
		0.0, 1.0, 0.0,
		0.0, 0.0, 0.0
    );

	vec3 sampleTex[9];

	for (int i = 0; i < 9; i++) {
		vec4 colorSample = texture(t_Screen, v_Uv.xy + offsets[i]);
		sampleTex[i] = vec3(colorSample);
	}

	vec3 color = vec3(0.0);

	for (int i = 0; i < 9; i++) {
		color += sampleTex[i] * kernel[i];
	}

	Target0 = vec4(color, 1.0);
	#else
	Target0 = vec4(texture(t_Screen, v_Uv.xy).xyz, 1.0);
	#endif
}
