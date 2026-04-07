uniform float uProgress;
uniform float uColorIntensity;
uniform float uSpeed;
uniform vec3 uColor;
uniform sampler2D uNoiseTexture;

uniform float uArcLength[8];
uniform float uArcRadius[8];
uniform float uArcThickness[8];
uniform float uArcRotation[8];
uniform float uArcSpeed[8];
uniform float uArcStartingRadius[8];
uniform float uArcEnabled[8];

in vec2 vUv;

vec2 rotateUv(vec2 uv, float rotationDegrees) {
  float angle = radians(rotationDegrees);
  mat2 rotationMatrix = mat2(
    cos(angle),
    -sin(angle),
    sin(angle),
    cos(angle)
  );

  return rotationMatrix * uv;
}

float taperArc(vec2 p, float r, float th, float arcHalf) {
    float angle = atan(p.x, p.y);
    float dist = length(p);
    float t = clamp(abs(angle) / arcHalf, 0.0, 1.0);
    float tapered = th * (1.0 - t * t);
    float arcDist = abs(dist - r) - tapered;
    float cutoff = abs(angle) - arcHalf;
    float arcDistance =  max(arcDist, cutoff);

    return 1.0 - smoothstep(0.0, 0.001, arcDistance);;
}

float createArcEffect(
  vec2 centeredArcUv,

  float arcSizeDegrees,
  float arcRadius,
  float arcThickness,
  float arcRotationDegrees,

  float speed,
  float startingRadius
) {
  float angle = radians(arcRotationDegrees);
  float xCoeff = sin(angle);
  float yCoeff = -cos(angle);

  centeredArcUv.x -= (arcRadius - startingRadius) * xCoeff;
  centeredArcUv.y -= (arcRadius - startingRadius) * yCoeff;

  centeredArcUv.x += uProgress * speed * xCoeff;
  centeredArcUv.y += uProgress * speed * yCoeff;

  centeredArcUv = rotateUv(centeredArcUv, arcRotationDegrees);

  float arcShape = taperArc(
    centeredArcUv,
    arcRadius,
    arcThickness,
    radians(arcSizeDegrees)
  );

  return arcShape;
}

void main() {
  vec2 centeredUv = vUv - 0.5;
  float radius = min(uProgress * uSpeed, 1.0);

  // Use circle SDF
  vec3 explosionColor =
    vec3((0.4 + radius * 0.1) - length(centeredUv) * 2.0) // Inner circle
    * vec3(length(centeredUv) * 2.0 - radius / 2.0) // Mask out outer circle
    * uColor * uColorIntensity; // Increase color saturation

  float totalArcShape = 0.0;
  for (int i = 0; i < 8; i++) {
    totalArcShape += uArcEnabled[i] * createArcEffect(
      centeredUv,
      uArcLength[i],
      uArcRadius[i],
      uArcThickness[i],
      uArcRotation[i],
      uArcSpeed[i],
      uArcStartingRadius[i]
    );
  }

  vec2 noiseUv = vUv;
  noiseUv *= 2.0;
  noiseUv.y -= uProgress * 1.5;
  noiseUv.x -= uProgress * 1.5;
  vec4 noiseTexture = texture2D(uNoiseTexture, noiseUv);

  float fadeIn = smoothstep(0.0, 0.3, uProgress);
  float fadeOut = 1.0 - smoothstep(0.3, 1.0, uProgress);
  float arcOpacity = fadeIn * fadeOut;

  vec3 allArcColor = mix(
    totalArcShape * noiseTexture.rgb * arcOpacity,
    vec3(0.0),
    uProgress * 3.0
  );

  gl_FragColor = vec4(
    max(explosionColor, vec3(0.0))
    +
    allArcColor, 1.0);
}