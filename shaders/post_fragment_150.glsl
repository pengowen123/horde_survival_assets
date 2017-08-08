#version 150 core

// TODO: Implement anti-aliasing resolve (it affects all othe graphics components, so wait until
//		 those are complete first)

in vec2 v_Uv;

uniform sampler2D t_Screen;

out vec4 Target0;

const float offset = 1.0 / 300.0;

void main() {
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
		1.0 / 16, 2.0 / 16, 1.0 / 16,
		2.0 / 16, 4.0 / 16, 2.0 / 16,
		1.0 / 16, 2.0 / 16, 1.0 / 16  
	);

	vec3 sampleTex[9];

	for (int i = 0; i < 9; i++) {
		// TODO: fix this
		//vec4 colorSample = texelFetch(t_Screen, v_Uv.xy + offsets[i], 1);
		//sampleTex[i] = vec3(colorSample);
	}

	vec3 color = vec3(0.0);

	for (int i = 0; i < 9; i++) {
		color += sampleTex[i] * kernel[i];
	}

	Target0 = vec4(color, 1.0);
	// Postprocessing disabled for now
	// TODO: take screen dimensions as a uniform
	Target0 = texture(t_Screen, v_Uv);

	// Apply gamma correction
	// TODO: make this a setting
	float gamma = 2.2;
	Target0.rgb = pow(Target0.rgb, vec3(2.2 / gamma));
}

