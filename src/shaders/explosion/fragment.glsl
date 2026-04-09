uniform float uTime;
uniform vec2 uErosionTimeFactor;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform sampler2D uNoiseTexture;
uniform sampler2D uErosionTexture;

in vec2 vUv;
in float vExplosionProgress;
in float vErosionProgress;

// Обозначения
// smthShape - маска, пиксель отвечающий за форму (на переменны такого типа умножают все остальное)
// smthUv - uv координаты скопированные для модификации в контексте отдельной текстуры
// smthTexture - vec4, результат texture2D
// smthColor - vec3, vec2 или float, цвет пикселя/ пикселей, результат smthTexture.rgb, smthTexture.rg, smthTexture.r
// smthAlpha - float, прозрачность цвета

void main() {
  vec2 noiseUv = vUv;
  // Make noise image smaller and center it
  noiseUv *= 2.0;
  noiseUv -= 0.5;
  // Move noise with time
  noiseUv.y += uTime * 2.0;
  noiseUv.x += uTime * 4.0;

  vec4 noiseTexture = texture2D(uNoiseTexture, noiseUv);
  vec3 noiseTextureColored = 
    noiseTexture.rgb * uColor1            // Color white spots of noise map
    + (1.0 - noiseTexture.rgb) * uColor2; // Color black spots of noise map

  float isExplosionEnded = step(1.0, vExplosionProgress);

  // Make noise texture appear from white to black
  float insideCircleAlphaShape = step(1.0 - vExplosionProgress, noiseTexture.r) * (1.0 - isExplosionEnded);

  vec2 erosionUv = vUv;
  erosionUv *= 0.2;
  erosionUv.x += uTime * uErosionTimeFactor.x;
  erosionUv.y += uTime * uErosionTimeFactor.y;
  vec4 erosionTexture = texture2D(uErosionTexture, erosionUv);

  float erosionAlpha = step(vErosionProgress, erosionTexture.r) * isExplosionEnded;

  gl_FragColor = vec4(noiseTextureColored, insideCircleAlphaShape + erosionAlpha);

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}

// Есть текстура шума
// В центре сфера - прозрачная в начале - ее не видно
// Начинает проявляеться текстура шума:
// - белый цвет текстуры становится выбранным цветом
// - черный цвет остается черным (либо вторым выбранным цветом)
// Сначала проявляется только белый цвет, то есть чем ближе к конце анимации тем чернее пиксели могут появляться