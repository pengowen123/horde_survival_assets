// Point light shader

struct PointLight {
	vec4 position;

	vec4 ambient;
	vec4 diffuse;
	vec4 specular;

	float constant;
	float linear;
	float quadratic;

	float enabled;
};

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
#define SHADOW_MAP_ROTATION {vec4(-1.0, 0.0, 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4( 0.0, 0.0, 0.0, 1.0)};

// Returns 0.0 if the provided position is in a shadow from the provided light, or 1.0 otherwise
/*float ShadowFactor(PointLight light, vec3 fragPos, float farPlane) {*/
	//vec3 fragToLight = fragPos - light.position.xyz;

	//// FIXME: This rotation should not be necessary
	//fragToLight = (SHADOW_MAP_ROTATION * vec4(fragToLight, 1.0)).xyz;

	//float closestDepth = texture(t_ShadowMap, fragToLight).r;

	//// Un-normalize the depth value
	//closestDepth *= farPlane;

	//float currentDepth = length(fragToLight);

	//// TODO: Fix peter panning
	//float bias = 0.05;
	//float shadow = currentDepth - bias > closestDepth ? 0.0 : 1.0;

	//return shadow;
/*}*/
