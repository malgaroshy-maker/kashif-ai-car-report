import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

/**
 * The catalogue tier, exercised without the catalogue.
 *
 * Shapes here are copied from real responses recorded while probing the API
 * with sixteen part numbers off Libyan reports, so what is mocked is what it
 * actually sends — including the part that surprised: a single article comes
 * back dozens of times over, once per vehicle it fits.
 */

const BASE = "https://auto-parts-catalog.apiprofile.com";

/** As returned for BMW 13627566988, trimmed. */
const OEM_ROWS = [
  {
    articleId: 29227,
    articleSearchNo: "13 62 7 566 988",
    articleNo: "0 280 218 135",
    oemNo: [
      { oemBrand: "BMW", oemDisplayNo: "13 62 7 524 136" },
      { oemBrand: "BMW", oemDisplayNo: "13 62 7 566 988" },
    ],
  },
];

const DETAILS = {
  articleId: "29227",
  article: {
    articleId: 29227,
    articleNo: "0 280 218 135",
    supplierName: "BOSCH",
    articleProductName: "Mass Air Flow Sensor",
  },
};

const MEDIA = [
  { articleMediaType: "PDF", mediaInformation: "Manual", s3image: `${BASE}/x.pdf` },
  {
    articleMediaType: "JPG",
    mediaInformation: "Picture",
    s3image:
      "https://fsn1.your-objectstorage.com/tecdoc2025/media_files/images/30/first.webp",
  },
  {
    articleMediaType: "JPG",
    mediaInformation: "Picture",
    s3image:
      "https://fsn1.your-objectstorage.com/tecdoc2025/media_files/images/30/second.webp",
  },
];

function ok(body: unknown) {
  return { ok: true, status: 200, json: async () => body } as unknown as Response;
}
function fail(status: number) {
  return {
    ok: false,
    status,
    json: async () => ({}),
    text: async () => "",
  } as unknown as Response;
}

let fetchMock: ReturnType<typeof vi.fn>;

beforeEach(() => {
  vi.resetModules();
  process.env.AUTOPARTS_API_KEY = "apk_test";
  delete process.env.AUTOPARTS_BASE_URL;
  fetchMock = vi.fn();
  vi.stubGlobal("fetch", fetchMock);
});

afterEach(() => {
  delete process.env.AUTOPARTS_API_KEY;
  delete process.env.AUTOPARTS_BASE_URL;
  vi.unstubAllGlobals();
});

const load = () => import("@/lib/autoparts");

describe("an app with no catalogue key", () => {
  it("asks the catalogue nothing", async () => {
    delete process.env.AUTOPARTS_API_KEY;
    const { searchCataloguePartPhoto, isCatalogueConfigured } = await load();

    expect(isCatalogueConfigured()).toBe(false);
    expect(await searchCataloguePartPhoto("13627566988")).toBeNull();
    expect(fetchMock).not.toHaveBeenCalled();
  });
});

describe("the base URL the console prints", () => {
  it("does not end up with /api twice", async () => {
    // The console shows "auto-parts-catalog.apiprofile.com/api" and every
    // documented path also starts with /api. This is a mistake worth making
    // exactly once.
    process.env.AUTOPARTS_BASE_URL = "auto-parts-catalog.apiprofile.com/api";
    fetchMock.mockResolvedValue(ok([]));

    const { searchCataloguePartPhoto } = await load();
    await searchCataloguePartPhoto("13627566988");

    const url = String(fetchMock.mock.calls[0][0]);
    expect(url).toBe(
      `${BASE}/api/articles-oem/search-all-equal-oem-no/lang-id/4/article-oem-no/13627566988`
    );
    expect(url).not.toContain("/api/api");
  });

  it("adds the scheme when the console left it off", async () => {
    process.env.AUTOPARTS_BASE_URL = "auto-parts-catalog.apiprofile.com";
    fetchMock.mockResolvedValue(ok([]));
    const { searchCataloguePartPhoto } = await load();
    await searchCataloguePartPhoto("13627566988");
    expect(String(fetchMock.mock.calls[0][0]).startsWith(BASE)).toBe(true);
  });
});

describe("finding the photograph", () => {
  it("resolves a number to an article and the article to a picture", async () => {
    fetchMock
      .mockResolvedValueOnce(ok(OEM_ROWS))
      .mockResolvedValueOnce(ok(DETAILS))
      .mockResolvedValueOnce(ok(MEDIA));

    const { searchCataloguePartPhoto } = await load();
    const photo = await searchCataloguePartPhoto("13627566988");

    expect(photo?.imageUrl).toContain("first.webp");
    // What the picture is actually of, which the card prints under it.
    expect(photo?.article).toBe("BOSCH 0 280 218 135");
    expect(photo?.productName).toBe("Mass Air Flow Sensor");
  });

  it("sends the key as the header the API asks for", async () => {
    fetchMock.mockResolvedValue(ok([]));
    const { searchCataloguePartPhoto } = await load();
    await searchCataloguePartPhoto("13627566988");
    expect(fetchMock.mock.calls[0][1].headers["x-apiprofile-key"]).toBe("apk_test");
  });

  it("takes a picture and not the fitting manual", async () => {
    // The media endpoint returns PDFs and diagrams under the same roof.
    fetchMock
      .mockResolvedValueOnce(ok(OEM_ROWS))
      .mockResolvedValueOnce(ok(DETAILS))
      .mockResolvedValueOnce(ok(MEDIA));

    const { searchCataloguePartPhoto } = await load();
    expect((await searchCataloguePartPhoto("13627566988"))?.imageUrl).not.toContain(
      ".pdf"
    );
  });

  it("refuses an article that does not carry the number", async () => {
    // The endpoint is called "search all equal oem no" and is believed, but
    // believing a search endpoint for free is how every other tier in this
    // app got a wrong photograph.
    fetchMock.mockResolvedValueOnce(
      ok([{ articleId: 111, oemNo: [{ oemBrand: "BMW", oemDisplayNo: "13 62 7 524 136" }] }])
    );

    const { searchCataloguePartPhoto } = await load();
    expect(await searchCataloguePartPhoto("13627566988")).toBeNull();
    // Refused before the two follow-up calls, so a wrong row costs one request.
    expect(fetchMock).toHaveBeenCalledTimes(1);
  });

  it("matches however the catalogue punctuates the number", async () => {
    // It writes "13 62 7 566 988"; a report writes 13627566988.
    fetchMock
      .mockResolvedValueOnce(ok(OEM_ROWS))
      .mockResolvedValueOnce(ok(DETAILS))
      .mockResolvedValueOnce(ok(MEDIA));

    const { searchCataloguePartPhoto } = await load();
    expect(await searchCataloguePartPhoto("13627566988")).not.toBeNull();
  });

  it("answers nothing when the article has no picture", async () => {
    fetchMock
      .mockResolvedValueOnce(ok(OEM_ROWS))
      .mockResolvedValueOnce(ok(DETAILS))
      .mockResolvedValueOnce(ok([{ mediaInformation: "Manual", s3image: "x.pdf" }]));

    // Two of the sixteen probed numbers were exactly this: a real article,
    // no photograph. The card draws its schematic.
    const { searchCataloguePartPhoto } = await load();
    expect(await searchCataloguePartPhoto("13627566988")).toBeNull();
  });
});

describe("when the quota runs out", () => {
  it("gives up quietly so the next source can answer", async () => {
    const warn = vi.spyOn(console, "warn").mockImplementation(() => {});
    fetchMock.mockResolvedValueOnce(fail(429));

    // The free plan is 100 requests a month and each lookup spends two, so
    // this is the failure that will actually happen. It must look like "no
    // photo here" and not like an error.
    const { searchCataloguePartPhoto } = await load();
    expect(await searchCataloguePartPhoto("13627566988")).toBeNull();
    expect(warn.mock.calls.flat().join(" ")).toContain("429");
    warn.mockRestore();
  });
});

describe("a number too short to be one", () => {
  it("never leaves the app", async () => {
    const { searchCataloguePartPhoto } = await load();
    expect(await searchCataloguePartPhoto("1234")).toBeNull();
    expect(await searchCataloguePartPhoto("")).toBeNull();
    expect(fetchMock).not.toHaveBeenCalled();
  });
});
