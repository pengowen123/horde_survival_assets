#version 150 core

// Lighting pass shader
//
// The implementation of lighting calculations for each light type are in their respective shaders

in vec2 v_Uv;

uniform sampler2D t_Position;
uniform sampler2D t_Normal;
uniform sampler2D t_Color;
uniform sampler2D t_DirShadowMap;

uniform u_Locals {
     vec4 u_EyePos;
     mat4 u_DirLightSpaceMatrix;
};

uniform u_Material {
     float u_Material_shininess;
};

#include "sampling.glsl"
#include "dir_light.glsl"
#include "point_light.glsl"
#include "spot_light.glsl"

uniform u_DirLights {
     DirLight dirLights[MAX_DIR_LIGHTS];
};

uniform u_PointLights {
     PointLight pointLights[MAX_POINT_LIGHTS];
};

uniform u_SpotLights {
     SpotLight spotLights[MAX_SPOT_LIGHTS];
};

out vec4 Target0;

void main() {
    // Get data from geometry buffer
    vec3 fragPos = texture(t_Position, v_Uv).xyz;;
    vec3 norm = texture(t_Normal, v_Uv).xyz;
    vec4 color = texture(t_Color, v_Uv);
    vec4 diffuse = vec4(color.rgb, 1.0);
    float specular = color.a;
 
    vec3 viewDir = normalize(vec3(u_EyePos) - fragPos);
 
    vec4 result = vec4(0.0, 0.0, 0.0, 1.0);

    // Calculate shadow factor for the single directional light shadow source
    // (NOTE: the light must be at index 0)
    #if SHADOWS_ENABLED == 1
    float dirShadowFactor = DirShadowFactor(
        dirLights[0],
        u_DirLightSpaceMatrix * vec4(fragPos, 1.0),
        norm
    );
    #endif
 
    int i;
 
    // Calculate directional lights
    for (i = 0; i < MAX_DIR_LIGHTS; i++) {
        // Equivalent to this, but without the branch
        // float shadowFactor = 1.0;
        // if (dirLights[i].has_shadows > 0.0) {
        //     shadowFactor = dirShadowFactor;
        // }
        #if SHADOWS_ENABLED == 1
        float shadowFactor = 1.0 - ((1.0 - dirShadowFactor) * dirLights[i].has_shadows);
        #endif
        vec4 light = CalcDirLight(
            dirLights[i],
            norm,
            viewDir,
            diffuse,
            #if SHADOWS_ENABLED == 1
            specular,
            shadowFactor
            #else
            specular
            #endif
        );
        result += light * dirLights[i].enabled;
    }
 
    // Calculate point lights
    for (i = 0; i < MAX_POINT_LIGHTS; i++) {
        float shadowFactor = 1.0;
        vec4 light = CalcPointLight(
            pointLights[i],
            norm,
            viewDir,
            fragPos,
            diffuse,
            specular,
            1.0
        );

        result += light * pointLights[i].enabled;
    }

    // Calculate spot lights
    for (i = 0; i < MAX_SPOT_LIGHTS; i++) {
        float shadowFactor = 1.0;
        vec4 light = CalcSpotLight(
            spotLights[i],
            norm,
            viewDir,
            fragPos,
            diffuse,
            specular,
            shadowFactor
        );

        result += light * spotLights[i].enabled;
    }
 
    Target0 = vec4(result.xyz, 1.0);
}
