#version 420 core

struct PointLight {
	vec4 position;

	vec4 ambient;
	vec4 diffuse;
	vec4 specular;

	float constant;
	float linear;
	float quadratic;
};

vec4 CalcPointLight(
		PointLight light,
		vec3 normal,
		vec3 viewDir,
		vec3 fragPos,
		vec4 diffuse,
		float specular,
		float shadowFactor
	);

float ShadowFactor(PointLight light, vec3 fragPos, float farPlane);

in vec2 v_Uv;

out vec4 Target0;

uniform samplerCube t_ShadowMap;
uniform sampler2D t_Position;
uniform sampler2D t_Normal;
uniform sampler2D t_Color;
uniform sampler2D t_Target;

uniform u_Locals {
	vec4 u_EyePos;
	float u_FarPlane;
};

uniform u_Material {
	float u_Material_shininess;
};

uniform u_Light {
	PointLight light[1];
};

void main() {
	vec3 fragPos = texture(t_Position, v_Uv).xyz;;
	vec3 norm = texture(t_Normal, v_Uv).xyz;
	vec4 color = texture(t_Color, v_Uv);
	vec4 diffuse = vec4(color.rgb, 1.0);
	float specular = color.a;

	vec3 viewDir = normalize(vec3(u_EyePos) - fragPos);

	float shadow_factor = ShadowFactor(light[0], fragPos, u_FarPlane);

	vec3 light_addition =
		CalcPointLight(
			light[0],
			norm,
			viewDir,
			fragPos,
			diffuse,
			specular,
			shadow_factor
		).xyz;

	vec3 result = texture(t_Target, v_Uv).rgb + light_addition;

	Target0 = vec4(result, 1.0);
}

vec4 CalcPointLight(
		PointLight light,
		vec3 normal,
		vec3 viewDir,
		vec3 fragPos,
		vec4 t_diffuse,
		float t_specular,
		float shadowFactor
	) {

	vec3 lightDir = normalize(vec3(light.position) - fragPos);

	// Diffuse
	float diff = max(dot(normal, lightDir), 0.0);

	// Specular
	vec3 halfwayDir = normalize(lightDir + viewDir);
	float spec = pow(max(dot(normal, halfwayDir), 0.0), u_Material_shininess);

	// Attenuation
	float dist = length(vec3(light.position) - fragPos);
	float attenuation  = 1.0 / (
			light.constant +
			light.linear * dist +
			light.quadratic * dist);

	// Apply lighting maps and light properties
	vec4 ambient = light.ambient * t_diffuse;
	vec4 diffuse = light.diffuse * (diff * t_diffuse);
	vec4 specular = light.specular * (spec * t_specular);

	// Apply attenuation
	ambient *= attenuation;
	diffuse *= attenuation;
	specular *= attenuation;

	return (ambient + (diffuse + specular) * shadowFactor);
}

// NOTE: The shadow map must be rotated for correctness
const mat4 SHADOW_MAP_ROTATION = {
	vec4(-1.0, 0.0, 0.0, 0.0),
	vec4( 0.0, 0.0, 1.0, 0.0),
	vec4( 0.0, 1.0, 0.0, 0.0),
	vec4( 0.0, 0.0, 0.0, 1.0)
	};

// Returns 0.0 if the provided position is in a shadow from the provided light, or 1.0 otherwise
float ShadowFactor(PointLight light, vec3 fragPos, float farPlane) {
	vec3 fragToLight = fragPos - light.position.xyz;

	// FIXME: This rotation should not be necessary
	fragToLight = (SHADOW_MAP_ROTATION * vec4(fragToLight, 1.0)).xyz;

	float closestDepth = texture(t_ShadowMap, fragToLight).r;

	// Un-normalize the depth value
	closestDepth *= farPlane;

	float currentDepth = length(fragToLight);

	// TODO: Fix peter panning
	float bias = 0.05;
	float shadow = currentDepth - bias > closestDepth ? 0.0 : 1.0;

	return shadow;
}
