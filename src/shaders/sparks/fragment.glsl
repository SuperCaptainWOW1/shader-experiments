uniform float uProgress;
uniform float uSoftnessFactor;
uniform vec3 uColor;
uniform sampler2D uNoiseTexture;
in vec2 vUv;

// Нормализованный прогресс вдоль длины луча: 0.0 (начало) -> 1.0 (конец).
float getRayProgress(float distFromCenter, float fromDist, float toDist) {
  return clamp((distFromCenter - fromDist) / max(toDist - fromDist, 0.0001), 0.0, 1.0);
}

// Маска углового сектора с поддержкой wrap-around (корректно возле 0/360).
float getTiltedAngleMask(
  float angleDeg,
  float fromDeg,
  float toDeg,
  float softness,
  float tiltDeg,
  float rayProgress
) {
  float angleShift = mix(-tiltDeg, tiltDeg, rayProgress);
  float halfWidth = max((toDeg - fromDeg) * 0.5, 0.0001);
  float sectorCenter = (fromDeg + toDeg) * 0.5 + angleShift;
  float wrappedDelta = abs(mod(angleDeg - sectorCenter + 540.0, 360.0) - 180.0);
  return 1.0 - smoothstep(halfWidth, halfWidth + softness, wrappedDelta);
}

float getRay(
  float distFromCenter, float angleDeg,
  float textureMask,
  float fromDeg, float toDeg,
  float fromDist, float toDist,
  float softness,
  float tiltDeg
) {
  float rayProgress = getRayProgress(distFromCenter, fromDist, toDist);
  float angleMask = getTiltedAngleMask(angleDeg, fromDeg, toDeg, softness * uSoftnessFactor, tiltDeg, rayProgress);
  float distanceMask = step(fromDist, distFromCenter) * step(distFromCenter, toDist);
  float fade = 1.0 - smoothstep(fromDist, toDist, distFromCenter);
  return angleMask * distanceMask * textureMask * fade;
}

void main() {
  vec2 centeredUv = vUv * 2.0 - 1.0;
  float distFromCenter = length(centeredUv);

  vec3 color = uColor;

  float angleRad = atan(centeredUv.y, centeredUv.x); // -PI..PI
  float angleDeg = degrees(angleRad);                // -180..180
  angleDeg = angleDeg + 180.0;                       // 0..360

  float textureMask = texture2D(uNoiseTexture, vUv).r;

  float p = uProgress;
  float ray1 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    0.0, 3.5,
    p + 0.02, p + 0.13,
    0.8,
    3.1
  );
  float ray2 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    32.0, 35.0,
    p + 0.09, p + 0.20,
    0.8,
    -3.8
  );
  float ray3 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    58.0, 61.0,
    p + 0.01, p + 0.14,
    0.8,
    4.2
  );
  float ray4 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    90.0, 93.0,
    p + 0.12, p + 0.21,
    0.8,
    -2.9
  );
  float ray5 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    122.0, 125.0,
    p + 0.05, p + 0.16,
    0.8,
    3.5
  );
  float ray6 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    160.0, 163.0,
    p + 0.18, p + 0.28,
    0.8,
    -4.6
  );
  float ray7 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    198.0, 201.0,
    p + 0.07, p + 0.19,
    0.8,
    2.6
  );
  float ray8 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    238.0, 241.0,
    p + 0.14, p + 0.23,
    0.8,
    -3.3
  );
  float ray9 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    272.0, 275.0,
    p + 0.03, p + 0.15,
    0.8,
    4.8
  );
  float ray10 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    310.0, 313.0,
    p + 0.11, p + 0.20,
    0.8,
    -3.0
  );
  float ray11 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    340.0, 343.0,
    p + 0.08, p + 0.19,
    0.8,
    4.0
  );
  float ray12 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    14.0, 16.5,
    p + 0.16, p + 0.24,
    0.7,
    -2.4
  );
  float ray13 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    44.0, 46.0,
    p + 0.04, p + 0.13,
    0.7,
    3.7
  );
  float ray14 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    108.0, 110.0,
    p + 0.20, p + 0.28,
    0.7,
    -3.1
  );
  float ray15 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    176.0, 178.5,
    p + 0.06, p + 0.15,
    0.7,
    2.9
  );
  float ray16 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    256.0, 258.0,
    p + 0.22, p + 0.30,
    0.7,
    -4.0
  );
  float ray17 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    326.0, 328.0,
    p + 0.10, p + 0.19,
    0.7,
    3.4
  );

  float long1 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    18.0, 19.0,
    p + 0.00, p + 0.24,
    0.25,
    -5.0
  );
  float long2 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    142.0, 143.0,
    p + 0.15, p + 0.35,
    0.25,
    4.4
  );
  float long3 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    286.0, 287.0,
    p + 0.07, p + 0.31,
    0.25,
    -4.2
  );
  float long4 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    84.0, 84.8,
    p + 0.21, p + 0.38,
    0.18,
    5.2
  );
  float long5 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    228.0, 228.8,
    p + 0.12, p + 0.34,
    0.18,
    -5.4
  );

  float micro1 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    74.0, 74.7,
    p + 0.09, p + 0.13,
    0.2,
    2.8
  );
  float micro2 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    214.0, 214.7,
    p + 0.17, p + 0.21,
    0.2,
    -3.6
  );
  float micro3 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    52.0, 52.5,
    p + 0.05, p + 0.085,
    0.15,
    -2.2
  );
  float micro4 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    134.0, 134.5,
    p + 0.24, p + 0.28,
    0.15,
    2.6
  );
  float micro5 = getRay(
    distFromCenter, angleDeg,
    textureMask,
    292.0, 292.5,
    p + 0.13, p + 0.17,
    0.15,
    -3.0
  );

  float alpha = ray1 +
    ray2 +
    ray3 +
    ray4 +
    ray5 +
    ray6 +
    ray7 +
    ray8 +
    ray9 +
    ray10 +
    ray11 +
    ray12 +
    ray13 +
    ray14 +
    ray15 +
    ray16 +
    ray17 +
    long1 +
    long2 +
    long3 +
    long4 +
    long5 +
    micro1 +
    micro2 +
    micro3 +
    micro4 +
    micro5;

  alpha = clamp(alpha, 0.0, 1.0);

  gl_FragColor = vec4(color * alpha, alpha);
  
  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}