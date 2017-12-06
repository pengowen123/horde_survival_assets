#version 150 core

#include "sampling"

struct DirLight {
	vec4 direction;

	vec4 ambient;
	vec4 diffuse;
	vec4 specular;
};

vec4 CalcDirLight(
		DirLight light,
		vec3 normal,
		vec3 viewDir,
		vec4 diffuse,
		float specular,
		float shadowFactor
	);

float ShadowFactor(DirLight light, vec4 fragPosLightSpace, vec3 normal);

in vec2 v_Uv;

out vec4 Target0;

uniform sampler2D t_ShadowMap;
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
	DirLight light[1];
};

void main() {
	vec3 fragPos = texture(t_Position, v_Uv).xyz;;
	vec3 norm = texture(t_Normal, v_Uv).xyz;
	vec4 color = texture(t_Color, v_Uv);
	vec4 diffuse = vec4(color.rgb, 1.0);
	float specular = color.a;

	vec3 viewDir = normalize(vec3(u_EyePos) - fragPos);

	float shadow_factor = ShadowFactor(light[0], u_LightSpaceMatrix * vec4(fragPos, 1.0), norm);

	vec3 light_addition = CalcDirLight(light[0], norm, viewDir, diffuse, specular, shadow_factor).xyz;
	vec3 result = texture(t_Target, v_Uv).xyz + light_addition;

	Target0 = vec4(result, 1.0);
}

vec4 CalcDirLight(
		DirLight light,
		vec3 normal,
		vec3 viewDir,
		vec4 t_diffuse,
		float t_specular,
		float shadowFactor
	) {

	vec3 lightDir = normalize(-light.direction.xyz);

	// Diffuse
	float diff = max(dot(normal, lightDir), 0.0);

	// Specular
	vec3 halfwayDir = normalize(lightDir + viewDir);
	float spec = pow(max(dot(normal, halfwayDir), 0.0), u_Material_shininess);

	// Apply lighting maps and light properties
	vec4 ambient = light.ambient * t_diffuse;
	vec4 diffuse = light.diffuse * (diff * t_diffuse);
	vec4 specular = light.specular * (spec * t_specular);

	// Sum all lights and apply shadows
	return (ambient + (diffuse + specular) * shadowFactor);
}

// Returns 0.0 if the provided position is in a shadow from the provided light, or 1.0 otherwise
float ShadowFactor(DirLight light, vec4 fragPosLightSpace, vec3 normal) {
	vec3 lightDir = normalize(-light.direction.xyz);

	vec3 projCoords = fragPosLightSpace.xyz / fragPosLightSpace.w;
	projCoords = projCoords * 0.5 + 0.5;

	// TODO: Fix peter panning
	float bias = max(0.01 * (1.0 - dot(normal, lightDir)), 0.001);
	float depth = projCoords.z - bias;

	vec2 texelSize = 1.0 / textureSize(t_ShadowMap, 0);
	float shadow = SampleShadowMapLinear(t_ShadowMap, projCoords.xy, depth, texelSize);

	if (projCoords.z > 1.0) {
		shadow = 1.0;
	}

	return shadow;
}
