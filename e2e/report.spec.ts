import { test, expect, type Page } from "@playwright/test";

/**
 * The journey, on the built Worker: an empty board, a report, and the two
 * things a reader acts on physically — the wiring reference and the exported
 * file.
 *
 * The demo reports need no API key, which is what makes this suite runnable in
 * CI at all.
 */

async function openDemo(page: Page) {
  await page.goto("/");
  await page.getByRole("button", { name: "Toyota Corolla" }).click();
  await expect(page.getByRole("heading", { level: 1 })).toContainText("Toyota");
}

test.describe("the empty board", () => {
  test("says the key is the reader's own, and offers both demos", async ({ page }) => {
    await page.goto("/");
    // Bring-your-own-key is the product's central constraint. If this line
    // ever disappears, people will paste a key expecting us to hold it.
    await expect(page.getByText("يتخزّن في متصفحك")).toBeVisible();
    await expect(page.getByRole("button", { name: "BMW 528i (E39)" })).toBeVisible();
    await expect(page.getByRole("button", { name: "Toyota Corolla" })).toBeVisible();
  });

  test("teaches the fuse colour code before using it", async ({ page }) => {
    await page.goto("/");
    await expect(page.getByText("مفتاح الرموز")).toBeVisible();
    for (const tier of ["حرج", "متوسط", "ذاكرة", "سليم"]) {
      await expect(page.getByText(tier, { exact: true }).first()).toBeVisible();
    }
  });
});

test.describe("a report", () => {
  test("names the car, and never invents one", async ({ page }) => {
    await openDemo(page);
    await expect(page.getByText("JTDBR42E309SAMPLE")).toBeVisible();

    const body = await page.locator("body").innerText();
    for (const invented of ["LIBYA-OBD-SCAN", "OEM-GENUINE", "مركبة مفحوصة"]) {
      expect(body, `still shows ${invented}`).not.toContain(invented);
    }
  });

  test("ranks faults worst-first", async ({ page }) => {
    await openDemo(page);
    const banks = await page.locator("h2.k-bank, .k-bank").allInnerTexts();
    const order = banks.join(" ");
    expect(order.indexOf("متوسط")).toBeLessThan(order.indexOf("سليم"));
  });

  test("opens a fault's detail in place, without a dialog", async ({ page }) => {
    await openDemo(page);
    // Located by what it controls, not by its label: a disclosure renames
    // itself when it opens, so a name-based locator silently re-resolves to
    // the next still-collapsed fault and reports aria-expanded="false".
    const toggle = page.locator('[aria-controls="fault-P0102-body"]');
    const body = page.locator("#fault-P0102-body");

    await expect(toggle).toHaveAttribute("aria-expanded", "false");
    await expect(body).toBeHidden();

    await toggle.click();
    await expect(toggle).toHaveAttribute("aria-expanded", "true");
    await expect(body).toBeVisible();
    await expect(toggle).toHaveText("إخفاء التفاصيل");
    // Reading detail must not stack an overlay: a mechanic under a bonnet
    // should be able to open two faults and compare them.
    await expect(page.locator('[role="dialog"]')).toHaveCount(0);
  });
});

test.describe("the wiring reference", () => {
  test("says when it is general guidance rather than this car's diagram", async ({ page }) => {
    await openDemo(page);
    // B2321 is not in the reference table, so it must degrade honestly.
    await page.getByRole("button", { name: "الفيوز والفيشة" }).nth(2).click();

    const dialog = page.getByRole("dialog");
    await expect(dialog).toBeVisible();
    await expect(dialog).toContainText("إرشاد عام");
    await expect(dialog).toContainText("غير محدد");
    // The invented fuse number this screen used to print.
    await expect(dialog).not.toContainText("ECU-15A");
  });

  test("gives real data for a code that is on file", async ({ page }) => {
    await openDemo(page);
    await page.getByRole("button", { name: "الفيوز والفيشة" }).first().click();
    const dialog = page.getByRole("dialog");
    await expect(dialog).toContainText("من مرجع الأكواد");
    await expect(dialog).toContainText("P0102");
  });
});

test.describe("keyboard and assistive technology", () => {
  test("a sheet traps focus and hands it back on Escape", async ({ page }) => {
    await page.goto("/");
    const opener = page.getByRole("button", { name: "القاموس" });
    await opener.focus();
    await opener.press("Enter");

    const dialog = page.getByRole("dialog");
    await expect(dialog).toHaveAttribute("aria-modal", "true");
    await expect(page.locator("[data-autofocus]")).toBeFocused();

    // Tab must not walk out of the sheet and into the page behind it.
    for (let i = 0; i < 25; i++) await page.keyboard.press("Tab");
    expect(
      await dialog.evaluate((d) => d.contains(document.activeElement))
    ).toBe(true);

    await page.keyboard.press("Escape");
    await expect(dialog).toBeHidden();
    // Focus back on the exact control that opened it, not on <body>.
    await expect(opener).toBeFocused();
  });

  test("the skip link is the first stop and reaches the report", async ({ page }) => {
    await page.goto("/");
    await page.keyboard.press("Tab");
    const skip = page.locator("a.k-skip");
    await expect(skip).toBeFocused();
    await skip.press("Enter");
    await expect(page).toHaveURL(/#main$/);
  });
});

test.describe("the page holds together", () => {
  test("does not scroll sideways, in either size", async ({ page }) => {
    await openDemo(page);
    const overflow = await page.evaluate(
      () => document.documentElement.scrollWidth - document.documentElement.clientWidth
    );
    expect(overflow).toBeLessThanOrEqual(0);
  });

  test("logs no console error and makes no failed request", async ({ page }) => {
    const errors: string[] = [];
    const failed: string[] = [];
    page.on("console", (m) => m.type() === "error" && errors.push(m.text()));
    page.on("requestfailed", (r) => failed.push(r.url()));

    await openDemo(page);
    await page.waitForTimeout(2500); // let the lazy part-photo lookups settle

    expect(errors, errors.join("\n")).toEqual([]);
    expect(failed, failed.join("\n")).toEqual([]);
  });

  test("renders every text node at readable contrast", async ({ page }) => {
    await openDemo(page);
    const fails = await page.evaluate(() => {
      const parse = (c: string) => {
        const m = c.match(/rgba?\(([^)]+)\)/);
        if (!m) return null;
        const p = m[1].split(/[,\s/]+/).filter(Boolean).map(Number);
        return { r: p[0], g: p[1], b: p[2], a: p.length > 3 ? p[3] : 1 };
      };
      type C = { r: number; g: number; b: number; a: number };
      const lum = (c: C) => {
        const f = (v: number) => {
          v /= 255;
          return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
        };
        return 0.2126 * f(c.r) + 0.7152 * f(c.g) + 0.0722 * f(c.b);
      };
      const ratio = (a: C, b: C) => {
        const [x, y] = [lum(a), lum(b)].sort((p, q) => q - p);
        return (x + 0.05) / (y + 0.05);
      };
      const bgOf = (el: Element): C => {
        let n: Element | null = el;
        while (n && n !== document.documentElement) {
          const c = parse(getComputedStyle(n).backgroundColor);
          if (c && c.a > 0.5) return c;
          n = n.parentElement;
        }
        return { r: 255, g: 255, b: 255, a: 1 };
      };

      const out: string[] = [];
      document.querySelectorAll<HTMLElement>("*").forEach((el) => {
        if (!el.offsetParent && el !== document.body) return;
        const text = [...el.childNodes]
          .filter((n) => n.nodeType === 3)
          .map((n) => n.textContent!.trim())
          .join("");
        if (!text) return;
        const cs = getComputedStyle(el);
        const fg = parse(cs.color);
        if (!fg) return;
        const size = parseFloat(cs.fontSize);
        const large = size >= 24 || (size >= 18.66 && parseInt(cs.fontWeight, 10) >= 700);
        const need = large ? 3 : 4.5;
        const r = ratio(fg, bgOf(el));
        if (r < need) out.push(`${text.slice(0, 30)} — ${r.toFixed(2)}:1`);
      });
      return out;
    });

    expect(fails, fails.join("\n")).toEqual([]);
  });
});

test.describe("the deployment surface", () => {
  test("is installable and crawlable, and publishes no build internals", async ({ request }) => {
    for (const path of ["/manifest.webmanifest", "/robots.txt", "/sitemap.xml", "/icon.svg"]) {
      expect((await request.get(path)).status(), path).toBe(200);
    }
    // The leak this whole migration exists to close.
    for (const path of [
      "/server/app/index.html",
      "/required-server-files.json",
      "/build-manifest.json",
    ]) {
      expect((await request.get(path)).status(), path).toBe(404);
    }
  });

  test("refuses an empty analysis instead of answering one", async ({ request }) => {
    const res = await request.post("/api/analyze", { data: {} });
    expect(res.status()).toBe(400);
    expect(await res.text()).not.toContain("report");
  });
});
