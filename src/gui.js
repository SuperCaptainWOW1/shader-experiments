import { Pane } from "tweakpane";
// import * as EssentialsPlugin from "@tweakpane/plugin-essentials";

const gui = new Pane({
  title: "Shader debug",
  expanded: true,
});
// gui.registerPlugin(EssentialsPlugin);

export const IS_MOBILE_PLATFORM = !window.matchMedia(
  "(hover: hover) and (pointer: fine)",
).matches;

gui.element.style.marginTop = "40px";
gui.element.style.overflowY = "auto";
gui.element.style.maxHeight = "calc(100vh - 80px)";
gui.element.style.minHeight = IS_MOBILE_PLATFORM ? "auto" : "400px";
gui.element.parentElement.style.width = "350px";

export default gui;
