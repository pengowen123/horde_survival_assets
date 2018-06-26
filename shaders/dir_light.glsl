// Directional light shader

struct DirLight {
	vec4 direction;

	vec4 ambient;
	vec4 diffuse;
	vec4 specular;

	float has_shadows;
	float enabled;
	
	vec2 _padding;
};

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
float DirShadowFactor(DirLight light, vec4 fragPosLightSpace, vec3 normal) {
	vec3 lightDir = normalize(-light.direction.xyz);

	vec3 projCoords = fragPosLightSpace.xyz / fragPosLightSpace.w;
	projCoords = projCoords * 0.5 + 0.5;

	// TODO: Fix peter panning
	float bias = max(0.01 * (1.0 - dot(normal, lightDir)), 0.001);
	float depth = projCoords.z - bias;

	vec2 texelSize = 1.0 / textureSize(t_DirShadowMap, 0);
	float shadow = SampleShadowMapLinear(t_DirShadowMap, projCoords.xy, depth, texelSize);

	if (projCoords.z > 1.0) {
		shadow = 1.0;
	}

	return shadow;
}
