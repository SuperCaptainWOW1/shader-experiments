uniform float uTime;
uniform float uProgress;

out vec2 vUv;

const float explosionDuration = 1.0;

void main() {
  vUv = uv;

  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}
