import { defineConfig } from "@docmd/core";
import vars from "./vars.json" with { type: "json" };

const handlebarsPlugin = new URL("./plugins/handlebars-plugin.js", import.meta.url).href;
const customPlugin = new URL("./plugins/custom-plugin.js", import.meta.url).href;

export default defineConfig({
  plugins: {
    [handlebarsPlugin]: {},
    [customPlugin]: {},
  },
  title: vars.title,
  theme: {
    customCss: ["assets/custom.css"],
  },
  favicon: "assets/favicon.png",
  logo: {
    light: "assets/logo.png",
    dark: "assets/logo.png",
    href: "/",
    alt: "{{orgName}} Hub Logo",
    // height: "32px",
  },
  layout: {
    breadcrumbs: false,
    footer: {
      branding: false,
    },
  },
});
