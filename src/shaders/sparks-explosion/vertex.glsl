uniform float uTime;
uniform float uProgress;

out vec2 vUv;

void main() {
  vUv = uv;

  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}
