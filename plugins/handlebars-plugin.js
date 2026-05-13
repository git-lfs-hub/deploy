import Handlebars from "handlebars";
import vars from "../vars.json" with { type: "json" };

export const plugin = {
  name: "handlebars-preprocessor",
  version: "1.0.0",
  capabilities: ["build"],
};

export function onBeforeParse(src) {
  return Handlebars.compile(src)(vars);
}
