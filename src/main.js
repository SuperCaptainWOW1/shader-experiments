import "./style.css";
import {
  AdditiveBlending,
  Color,
  Mesh,
  PerspectiveCamera,
  PlaneGeometry,
  RepeatWrapping,
  Scene,
  ShaderMaterial,
  SphereGeometry,
  SRGBColorSpace,
  TextureLoader,
  Timer,
  Uniform,
  WebGLRenderer,
} from "three";
import gsap from "gsap";

import fireVertexShader from "./shaders/fire/vertex.glsl";
import fireFragmentShader from "./shaders/fire/fragment.glsl";

import explosionVertexShader from "./shaders/explosion/vertex.glsl";
import explosionFragmentShader from "./shaders/explosion/fragment.glsl";

import smokeVertexShader from "./shaders/smoke/vertex.glsl";
import smokeFragmentShader from "./shaders/smoke/fragment.glsl";
import gui from "./gui";

const animationOptions = {
  duration: 1,
};

const textureLoader = new TextureLoader();

async function start() {
  const renderer = new WebGLRenderer({
    powerPreference: "high-performance",
    antialias: true,
    alpha: true,
  });
  renderer.outputColorSpace = SRGBColorSpace;
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  document.body.append(renderer.domElement);

  const camera = new PerspectiveCamera(
    22.5,
    window.innerWidth / window.innerHeight,
    0.01,
    2000,
  );
  camera.position.z = 8;

  const scene = new Scene();
  scene.background = new Color("#212121");
  scene.add(camera);

  const timer = new Timer();

  gui
    .addBinding(animationOptions, "duration", {
      label: "Effect duration",
      min: 0,
      max: 5,
    })
    .on("change", () => {
      tween.duration(animationOptions.duration);
    });

  const explosionShaderMaterial = await getExplosionMaterial();
  const smokeShaderMaterial = await getSmokeMaterial();

  // const controls = new OrbitControls(camera, renderer.domElement);

  renderer.setAnimationLoop((t) => {
    timer.update(t);
    // controls.update(t);

    explosionShaderMaterial.uniforms.uTime.value = timer.getElapsed();
    explosionShaderMaterial.needsUpdate = true;
    smokeShaderMaterial.uniforms.uTime.value = timer.getElapsed();
    smokeShaderMaterial.needsUpdate = true;

    renderer.render(scene, camera);
  });

  window.addEventListener("resize", () => {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();

    renderer.setSize(window.innerWidth, window.innerHeight);
  });

  const sphere = new Mesh(new SphereGeometry(), explosionShaderMaterial);
  scene.add(sphere);

  const plane = new Mesh(new PlaneGeometry(), smokeShaderMaterial);
  plane.lookAt(camera.position);
  scene.add(plane);

  const tween = gsap.fromTo(
    [
      explosionShaderMaterial.uniforms.uProgress,
      smokeShaderMaterial.uniforms.uProgress,
    ],
    {
      value: 0,
    },
    {
      value: animationOptions.duration,

      ease: "none",
      duration: 1,

      onStart: () => {
        explosionShaderMaterial.visible = true;
        smokeShaderMaterial.visible = true;
      },
      onComplete: () => {
        explosionShaderMaterial.visible = false;
        smokeShaderMaterial.visible = false;
      },
    },
  );

  window.addEventListener("click", () => {
    tween.play(0);
  });
}

async function getFireMaterial() {
  const fireTexture = await textureLoader.loadAsync(
    "src/assets/noise-textures/fire.png",
  );
  fireTexture.colorSpace = SRGBColorSpace;
  fireTexture.wrapS = RepeatWrapping;
  fireTexture.wrapT = RepeatWrapping;

  const noiseTexture = await textureLoader.loadAsync(
    "src/assets/noise-textures/noise_small.png",
  );
  noiseTexture.wrapS = RepeatWrapping;
  noiseTexture.wrapT = RepeatWrapping;

  const alphaErosionTexture = await textureLoader.loadAsync(
    "src/assets/noise-textures/lichen.jpg",
  );
  alphaErosionTexture.wrapS = RepeatWrapping;
  alphaErosionTexture.wrapT = RepeatWrapping;

  const shaderMaterial = new ShaderMaterial({
    vertexShader: fireVertexShader,
    fragmentShader: fireFragmentShader,
    uniforms: {
      uTime: new Uniform(0),
      uTexture: new Uniform(fireTexture),
      uNoiseTexture: new Uniform(noiseTexture),
      uAlphaErosionTexture: new Uniform(alphaErosionTexture),
    },
  });

  return shaderMaterial;
}

async function getExplosionMaterial() {
  const options = {
    color1: "#f7721a",
    color2: "#dda965",
  };

  const noiseTexture = await textureLoader.loadAsync(
    "src/assets/noise-textures/milky10.png",
  );
  noiseTexture.colorSpace = SRGBColorSpace;
  noiseTexture.wrapS = RepeatWrapping;
  noiseTexture.wrapT = RepeatWrapping;

  const vertexNoiseTexture = await textureLoader.loadAsync(
    "src/assets/noise-textures/perlin23.png",
  );
  vertexNoiseTexture.colorSpace = SRGBColorSpace;
  vertexNoiseTexture.wrapS = RepeatWrapping;
  vertexNoiseTexture.wrapT = RepeatWrapping;

  const shaderMaterial = new ShaderMaterial({
    vertexShader: explosionVertexShader,
    fragmentShader: explosionFragmentShader,
    transparent: true,
    depthWrite: false,
    uniforms: {
      uTime: new Uniform(0),
      uProgress: new Uniform(0),
      uNoiseTexture: new Uniform(noiseTexture),
      uVertexNoiseTexture: new Uniform(vertexNoiseTexture),
      uColor1: new Uniform(new Color(options.color1)),
      uColor2: new Uniform(new Color(options.color2)),
    },
    visible: false,
  });

  const guiFolder = gui.addFolder({
    title: "Explosion",
  });

  guiFolder
    .addBinding(options, "color1", {
      label: "Color 1",
    })
    .on("change", () => {
      shaderMaterial.uniforms.uColor1.value = new Color(options.color1);
    });
  guiFolder
    .addBinding(options, "color2", {
      label: "Color 2",
    })
    .on("change", () => {
      shaderMaterial.uniforms.uColor2.value = new Color(options.color2);
    });

  return shaderMaterial;
}

async function getSmokeMaterial() {
  const options = {
    color: "#dda965",
    colorIntensity: 20,
    speed: 1.5,
  };

  const shaderMaterial = new ShaderMaterial({
    vertexShader: smokeVertexShader,
    fragmentShader: smokeFragmentShader,
    transparent: true,
    blending: AdditiveBlending,
    depthWrite: false,
    uniforms: {
      uTime: new Uniform(0),
      uProgress: new Uniform(0),
      uColor: new Uniform(new Color("#dda965")),
      uColorIntensity: new Uniform(20),
      uSpeed: new Uniform(1),
    },
    visible: false,
  });

  const guiFolder = gui.addFolder({
    title: "Smoke",
  });

  guiFolder
    .addBinding(options, "color", {
      label: "Color",
    })
    .on("change", () => {
      shaderMaterial.uniforms.uColor.value = new Color(options.color);
    });
  guiFolder
    .addBinding(options, "colorIntensity", {
      label: "Color intensity",
      min: 0,
      max: 100,
    })
    .on("change", () => {
      shaderMaterial.uniforms.uColorIntensity.value = options.colorIntensity;
    });
  guiFolder
    .addBinding(options, "speed", {
      label: "Speed",
      min: 0,
      max: 5,
    })
    .on("change", () => {
      shaderMaterial.uniforms.uSpeed.value = options.speed;
    });

  return shaderMaterial;
}

start();
