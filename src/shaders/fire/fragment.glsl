const float MULTIPLIER = 5.0;

uniform float uTime;
uniform sampler2D uTexture;
uniform sampler2D uNoiseTexture;
uniform sampler2D uAlphaErosionTexture;

in vec2 vUv;

void main() {

  vec2 noiseUv = vUv;
  // Move noise texture down
  noiseUv.y += uTime * MULTIPLIER;
  noiseUv *= 0.4;

  vec4 noiseTextureColor = texture(uNoiseTexture, noiseUv);

  vec2 textureUv = vUv;
  // Move our texture uv horizontally to create a small distortion
  textureUv.x += (noiseTextureColor.r - 0.5) * 0.02;
  textureUv.y += (noiseTextureColor.r) * 0.01;

  vec4 textureColor = texture(uTexture, textureUv);

  vec2 alphaErosionTextureUv = vUv;
  alphaErosionTextureUv.x += uTime * 2.5;

  vec4 alphaErosionColor = texture(uAlphaErosionTexture, alphaErosionTextureUv);
  float alphaErosionIntensity = mix(alphaErosionColor.r, 1.0, 1.0);

  gl_FragColor = vec4(textureColor.rgb, alphaErosionIntensity);

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}