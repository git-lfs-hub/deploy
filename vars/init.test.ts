import { describe, test, expect } from "vitest";
import { normalizeVars, resolveDefaults, deepMerge } from "./lib";

function resolveVars(
  varsInputRaw: Record<string, unknown>,
  rawDefaults: Record<string, unknown>,
): Record<string, unknown> {
  const varsInput = normalizeVars(varsInputRaw);
  return deepMerge(resolveDefaults(rawDefaults, varsInput), varsInput);
}

describe("resolveVars", () => {
  test("user var overrides default", () => {
    const vars = resolveVars({ org: "Mine" }, { org: "Default" });
    expect(vars.org).toBe("Mine");
  });

  test("default fills in missing user var", () => {
    const vars = resolveVars({}, { org: "Default" });
    expect(vars.org).toBe("Default");
  });

  test("default key already set by user is excluded from defaults rendering", () => {
    const vars = resolveVars({ org: "Mine" }, { org: "{{org}}" });
    expect(vars.org).toBe("Mine");
  });

  test("default can reference a user var via template", () => {
    const vars = resolveVars(
      { github: { org: "myorg" } },
      { github: { home: "https://github.com/{{github.org}}" } },
    );
    expect((vars.github as Record<string, unknown>).home).toBe("https://github.com/myorg");
  });

  test("default can reference another default via user var", () => {
    const vars = resolveVars(
      { cloudflare: { accountSlug: "acme" } },
      { lfs: { server: "lfs.{{cloudflare.accountSlug}}.workers.dev" } },
    );
    expect((vars.lfs as Record<string, unknown>).server).toBe("lfs.acme.workers.dev");
  });

  test("default can reference another default (chained)", () => {
    const vars = resolveVars(
      { cloudflare: { accountSlug: "acme" } },
      {
        lfs: { server: "lfs.{{cloudflare.accountSlug}}.workers.dev" },
        github: { appHome: "https://{{lfs.server}}" },
      },
    );
    expect((vars.lfs as Record<string, unknown>).server).toBe("lfs.acme.workers.dev");
    expect((vars.github as Record<string, unknown>).appHome).toBe("https://lfs.acme.workers.dev");
  });

  test("optional vars get empty-string defaults", () => {
    const vars = resolveVars({}, {});
    const gh = vars.github as Record<string, unknown>;
    expect(gh.org).toBe("");
    expect(gh.user).toBe("");
    expect(gh.orgs).toBe("");
  });

  test("user vars take precedence over defaults in final merge", () => {
    const vars = resolveVars(
      { org: "User" },
      { org: "Default", extra: "from-default" },
    );
    expect(vars.org).toBe("User");
    expect(vars.extra).toBe("from-default");
  });
});
