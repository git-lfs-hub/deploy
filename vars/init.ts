/**
 * Renders deployment artifacts from Handlebars templates (repo root):
 * - wrangler.jsonc ← server/wrangler.template.jsonc
 * - github-app.md ← server/github-app.template.md
 * Context is read from vars.json in @root (first arg).
 */

import { existsSync } from "node:fs";
import { resolve } from "node:path";
import { loadInputVars, loadDefaultVars, deepMerge, renderTemplateFile, validateSchema, writeJsonFile } from "./lib";

const pkg = import.meta.dir;
const ws = resolve(pkg, '..');

const inputPath = resolve(ws, "vars.json");
const input = loadInputVars(inputPath);

const defaultsPath = resolve(pkg, "vars.defaults.json");
const defaults = loadDefaultVars(defaultsPath, input, { vars: inputPath });

const vars = deepMerge(defaults, input);
validateSchema(vars, resolve(pkg, "vars.schema.json"));
writeJsonFile(resolve(ws, "vars.resolved.json"), vars);

function render(templateRel: string, outRel: string) {
  renderTemplateFile(resolve(ws, templateRel), resolve(ws, outRel), vars, inputPath);
}

if (!existsSync(resolve(ws, "wrangler.jsonc"))) {
  render("server/wrangler.template.jsonc", "wrangler.jsonc");
}
render("server/github-app.template.md", "github-app.md");
