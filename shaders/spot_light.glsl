// Spot light shader
struct SpotLight {
    vec4 position;
    vec4 direction;

    vec4 ambient;
    vec4 diffuse;
    vec4 specular;

    float constant;
    float linear;
    float quadratic;

    float cutOff;
    float outerCutOff;

    float enabled;

    vec2 _padding;
};
    
vec4 CalcSpotLight(
        SpotLight light,
        vec3 normal,
        vec3 viewDir,
        vec3 fragPos,
        vec4 t_diffuse,
        float t_specular,
        float shadowFactor
    ) {

    vec3 lightDir = normalize(vec3(light.position) - fragPos);

    vec4 result;

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

    // Calculate intensity of the spotlight based on the angle
    float theta = dot(lightDir, normalize(vec3(-light.direction)));
    float epsilon = light.cutOff - light.outerCutOff;
    float intensity = clamp((theta - light.outerCutOff) / epsilon, 0.0, 1.0);

    diffuse *= intensity;
    specular *= intensity;

    // Sum all lights and apply shadows
    return (ambient + (diffuse + specular) * shadowFactor);
}
