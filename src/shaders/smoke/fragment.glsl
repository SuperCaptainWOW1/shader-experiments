uniform float uProgress;
uniform float uColorIntensity;
uniform float uSpeed;
uniform vec3 uColor;

in vec2 vUv;

void main() {
  vec2 centeredUv = vUv - 0.5;
  float radius = min(uProgress * uSpeed, 1.0);

  // Circle SDF
  vec3 explosionColor =
    vec3((0.4 + radius * 0.1) - length(centeredUv)) // Inner circle
    * vec3(length(centeredUv) - radius / 2.0) // Mask out outer circle
    * uColor * uColorIntensity; // Increase color saturation

  gl_FragColor = vec4(explosionColor, 1.0);
}