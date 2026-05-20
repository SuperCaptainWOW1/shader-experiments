uniform sampler2D uAtlas;
uniform float uTime;
uniform float uProgress;
uniform vec3 uColor;

in vec2 vUv;

void main() {
  const float COLUMNS = 7.0;
  const float ROWS = 5.0;
  const float FRAME_COUNT = 35.0;
  const float FPS = 30.0;

  float frameIndex = mod(floor(uProgress * FPS), FRAME_COUNT);

  float column = mod(frameIndex, COLUMNS);
  float rowFromTop = floor(frameIndex / COLUMNS);
  float row = ROWS - 1.0 - rowFromTop;

  const float INSET = 0.01;
  const float Y_OFFSET = 0.02; // + опускает картинку вниз
  vec2 frameUv = vUv * (1.0 - INSET * 2.0) + INSET;
  frameUv.y = clamp(frameUv.y + Y_OFFSET, INSET, 1.0 - INSET);
  vec2 atlasUv = (vec2(column, row) + frameUv) / vec2(COLUMNS, ROWS);

  vec4 tex = texture2D(uAtlas, atlasUv);

  gl_FragColor = vec4(vec3(tex) * uColor, tex.r);

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}