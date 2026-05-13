import vars from "../vars.json" with { type: "json" };

export const plugin = {
  name: "custom",
  version: "1.0.0",
  capabilities: ["build"],
};

export function onPageReady(page) {
  page.html = page.html.replace(
    /(<a [^>]*class="logo-link"[^>]*>[\s\S]*?<\/a>)/,
    `$1<span class="logo-title">${vars.title}</span>`,
  );
}
