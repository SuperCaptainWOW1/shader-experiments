import { Pane } from "tweakpane";
// import * as EssentialsPlugin from "@tweakpane/plugin-essentials";

const gui = new Pane({
  title: "Shader debug",
  expanded: true,
});
// gui.registerPlugin(EssentialsPlugin);

gui.element.style.marginTop = "40px";
gui.element.parentElement.style.width = "350px";

export default gui;
