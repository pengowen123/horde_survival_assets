// Texture sampling utilities

float SampleShadowMap(sampler2D shadowMap, vec2 coords, float compare) {
    return step(compare, texture(shadowMap, coords).r);
}

float SampleShadowMapLinear(sampler2D shadowMap, vec2 coords, float compare, vec2 texelSize) {
    vec2 pixelPos = (coords / texelSize) + vec2(0.5);
    vec2 fractPart = fract(pixelPos);
    vec2 startTexel = (pixelPos - fractPart) * texelSize;

    // A 2x2 square of pixels to interpolate between
    float blTexel = SampleShadowMap(shadowMap, startTexel, compare);
    float brTexel = SampleShadowMap(shadowMap, startTexel + vec2(texelSize.x, 0.0), compare);
    float tlTexel = SampleShadowMap(shadowMap, startTexel + vec2(0.0, texelSize.y), compare);
    float trTexel = SampleShadowMap(shadowMap, startTexel + texelSize, compare);

    // Interpolate the left column
    float mixLeft = mix(blTexel, tlTexel, fractPart.y);

    // Interpolate the right column
    float mixRight = mix(brTexel, trTexel, fractPart.y);

    return mix(mixLeft, mixRight, fractPart.x);
}
