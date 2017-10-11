#version 150 core

struct SpotLight {
	vec4 position;
	vec4 direction;

	vec4 ambient;
	vec4 diffuse;
	vec4 specular;

	float cutOff;
	float outerCutOff;
};

vec4 CalcSpotLight(
		SpotLight light,
		vec3 normal,
		vec3 viewDir,
		vec3 fragPos,
		vec4 diffuse,
		float specular
	);

in vec2 v_Uv;

out vec4 Target0;

uniform sampler2D t_Position;
uniform sampler2D t_Normal;
uniform sampler2D t_Color;
uniform sampler2D t_Target;

uniform u_Locals {
	vec4 u_EyePos;
	mat4 u_LightSpaceMatrix;
};

uniform u_Material {
	float u_Material_shininess;
};

uniform u_Light {
	SpotLight light[1];
};

void main() {
	vec3 fragPos = texture(t_Position, v_Uv).xyz;;
	vec3 norm = texture(t_Normal, v_Uv).xyz;
	vec4 color = texture(t_Color, v_Uv);
	vec4 diffuse = vec4(color.rgb, 1.0);
	float specular = color.a;

	vec3 viewDir = normalize(vec3(u_EyePos) - fragPos);

	vec3 light_addition = CalcSpotLight(light[0], norm, viewDir, fragPos, diffuse, specular).xyz;
	vec3 result = texture(t_Target, v_Uv).xyz + light_addition;

	Target0 = vec4(result, 1.0);
}

vec4 CalcSpotLight(
		SpotLight light,
		vec3 normal,
		vec3 viewDir,
		vec3 fragPos,
		vec4 t_diffuse,
		float t_specular
	) {

	vec3 lightDir = normalize(vec3(light.position) - fragPos);

	vec4 result;

	// Diffuse
	float diff = max(dot(normal, lightDir), 0.0);

	// Specular
	vec3 halfwayDir = normalize(lightDir + viewDir);
	float spec = pow(max(dot(normal, halfwayDir), 0.0), u_Material_shininess);

	// Apply lighting maps and light properties
	vec4 ambient = light.ambient * t_diffuse;
	vec4 diffuse = light.diffuse * (diff * t_diffuse);
	vec4 specular = light.specular * (spec * t_specular);

	// Calculate intensity of the spotlight based on the angle
	float theta = dot(lightDir, normalize(vec3(-light.direction)));
	float epsilon = light.cutOff - light.outerCutOff;
	float intensity = clamp((theta - light.outerCutOff) / epsilon, 0.0, 1.0);

	diffuse *= intensity;
	specular *= intensity;

	return (ambient + diffuse + specular);
}
