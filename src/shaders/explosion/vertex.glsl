const float vertexOffsetStrength = 0.3;
const float explosionDuration = 0.1;

uniform float uTime;
uniform float uProgress;
uniform sampler2D uVertexNoiseTexture;

out vec2 vUv;
out float vExplosionProgress;
out float vErosionProgress;

void main() {
  vUv = uv;
  
  float explosionProgress = min(uProgress * (1.0 / explosionDuration), 1.0);
  vExplosionProgress = explosionProgress;

  float erosionProgress = clamp((uProgress - explosionDuration) / (1.0 - explosionDuration), 0.0, 1.0);
  vErosionProgress = erosionProgress;

  vec2 vertexNoiseUv = uv - 0.5;
  vertexNoiseUv.y += uTime * 0.1;

  vec4 vertexNoiseTexture = texture2D(uVertexNoiseTexture, vertexNoiseUv);

  vec3 modifiedPosition = 
    position 
    // Use normal to move vertices in the normal facing directions
    + normal * (vertexNoiseTexture.r * vertexOffsetStrength)
    // Increase offset effect with time
    * explosionProgress;

  // Scale object over time 
  modifiedPosition *= 
    0.05                // - starting scale
    + explosionProgress // Scale the object with time
      * 0.2;            // - scale strength

  gl_Position = projectionMatrix * modelViewMatrix * vec4(modifiedPosition, 1.0);
}
