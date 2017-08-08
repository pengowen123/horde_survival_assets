#version 150 core

// A directional light
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
		float specular
	);

// A point light
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
		float specular
	);

// A spotlight
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

uniform u_Locals {
	vec4 u_EyePos;
};

uniform u_Material {
	float u_Material_shininess;
};

void main() {
	// Get data from geometry buffer
	vec3 fragPos = texture(t_Position, v_Uv).xyz;;
	vec3 norm = texture(t_Normal, v_Uv).xyz;
	vec4 color = texture(t_Color, v_Uv);
	vec4 diffuse = vec4(color.rgb, 1.0);
	float specular = color.a;

	vec3 viewDir = normalize(vec3(u_EyePos) - fragPos);

	PointLight light;

	light.position = vec4(5.0, 3.0, 6.5, 1.0);

	light.ambient = vec4(0.1, 0.1, 0.1, 1.0);
	light.diffuse = vec4(1.0, 1.0, 1.0, 1.0);
	light.specular = vec4(1.0, 1.0, 1.0, 1.0);

	light.constant = 1.0;
	light.linear = 0.14;
	light.quadratic = 0.07;

	vec4 result = vec4(0.0, 0.0, 0.0, 1.0);

	result += CalcPointLight(light, norm, viewDir, fragPos, diffuse, specular);

	Target0 = result;
}

vec4 CalcDirLight(
		DirLight light,
		vec3 normal,
		vec3 viewDir,
		vec4 t_diffuse,
		float t_specular
	) {

	vec3 lightDir = normalize(vec3(-light.direction));

	// Diffuse
	float diff = max(dot(normal, lightDir), 0.0);

	// Specular
	vec3 halfwayDir = normalize(lightDir + viewDir);
	float spec = pow(max(dot(normal, halfwayDir), 0.0), u_Material_shininess);

	// Apply lighting maps and light properties
	vec4 ambient = light.ambient * t_diffuse;
	vec4 diffuse = light.diffuse * (diff * t_diffuse);
	vec4 specular = light.specular * (spec * t_specular);

	return (ambient + diffuse + specular);
}

vec4 CalcPointLight(
		PointLight light,
		vec3 normal,
		vec3 viewDir,
		vec3 fragPos,
		vec4 t_diffuse,
		float t_specular
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

	return (ambient + diffuse + specular);
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
