uniform float uProgress;
uniform float uColorIntensity;
uniform float uSpeed;
uniform vec3 uColor;
uniform sampler2D uNoiseTexture;

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

  float arc1Shape = createArcEffect(
    centeredUv, // center
    45.0, // length (degrees)
    0.2, // radius
    0.005, // thickness
    7.0, // rotation (degrees)
    0.58, // speed
    0.11 // starting radius
  );

  float arc2Shape = createArcEffect(
    centeredUv, // center
    47.0, // length (degrees)
    0.2, // radius
    0.006, // thickness
    40.0, // rotation (degrees)
    0.6, // speed
    0.07 // starting radius
  );

  float arc3Shape = createArcEffect(
    centeredUv, // center
    42.0, // length (degrees)
    0.2, // radius
    0.0025, // thickness
    98.0, // rotation (degrees)
    0.54, // speed
    0.1 // starting radius
  );

  float arc4Shape = createArcEffect(
    centeredUv, // center
    40.0, // length (degrees)
    0.2, // radius
    0.0022, // thickness
    126.0, // rotation (degrees)
    0.4, // speed
    0.14 // starting radius
  );

  float arc5Shape = createArcEffect(
    centeredUv, // center
    38.0, // length (degrees)
    0.2, // radius
    0.002, // thickness
    188.0, // rotation (degrees)
    0.46, // speed
    0.12 // starting radius
  );

  float arc6Shape = createArcEffect(
    centeredUv, // center
    49.0, // length (degrees)
    0.2, // radius
    0.0055, // thickness
    231.0, // rotation (degrees)
    0.65, // speed
    0.08 // starting radius
  );


  float arc7Shape = createArcEffect(
    centeredUv, // center
    51.0, // length (degrees)
    0.2, // radius
    0.0062, // thickness
    266.0, // rotation (degrees)
    0.58, // speed
    0.06 // starting radius
  );

  float arc8Shape = createArcEffect(
    centeredUv, // center
    42.0, // length (degrees)
    0.2, // radius
    0.004, // thickness
    319.0, // rotation (degrees)
    0.42, // speed
    0.09 // starting radius
  );

  vec2 noiseUv = vUv;
  noiseUv *= 2.0;
  noiseUv.y -= uProgress * 1.5;
  noiseUv.x -= uProgress * 1.5;
  vec4 noiseTexture = texture2D(uNoiseTexture, noiseUv);

  float fadeIn = smoothstep(0.0, 0.3, uProgress);
  float fadeOut = 1.0 - smoothstep(0.3, 1.0, uProgress);
  float arcOpacity = fadeIn * fadeOut;

  vec3 allArcColor = mix(
    (arc1Shape + arc2Shape + arc3Shape + arc4Shape + arc5Shape + arc6Shape + arc7Shape + arc8Shape)
      * noiseTexture.rgb
      * arcOpacity
      ,
    vec3(0.0),
    uProgress * 3.0
  );

  gl_FragColor = vec4(
    max(explosionColor, vec3(0.0))
    +
    allArcColor, 1.0);
}