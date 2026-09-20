import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

/**
 * The OEM tier, exercised without eBay.
 *
 * This module was written against the documentation rather than against a live
 * account — the Developers Program approval takes a business day — so the
 * things that can be got wrong from a document are the things checked here:
 * the token request's shape, that a token is minted once rather than per
 * lookup, that a stale one is dropped, and that nothing at all happens when
 * the app has no credentials.
 *
 * What these cannot check is eBay's own answer: whether a Toyota part number
 * returns a listing, and whether that listing's photograph is any good. That
 * is measured against the real API once the account is live.
 *
 * Each test imports the module fresh, because the access token is cached in a
 * module-level variable and the whole point of two of these is what that
 * variable does.
 */

const CREDS = { EBAY_CLIENT_ID: "test-id", EBAY_CLIENT_SECRET: "test-secret" };

/** One listing, shaped the way Browse's `itemSummaries` entries are. */
function listing(title: string, thumb = "https://i.ebayimg.com/images/g/abc/s-l225.jpg") {
  return {
    title,
    itemWebUrl: "https://www.ebay.com/itm/123456789",
    image: { imageUrl: "https://i.ebayimg.com/images/g/abc/s-l1600.jpg" },
    thumbnailImages: [{ imageUrl: thumb }],
  };
}

function jsonResponse(body: unknown, status = 200) {
  return {
    ok: status >= 200 && status < 300,
    status,
    json: async () => body,
    text: async () => JSON.stringify(body),
  } as unknown as Response;
}

const TOKEN_BODY = { access_token: "v^1.1#token", expires_in: 7200 };

let fetchMock: ReturnType<typeof vi.fn>;

beforeEach(() => {
  vi.resetModules();
  for (const [k, v] of Object.entries(CREDS)) process.env[k] = v;
  fetchMock = vi.fn();
  vi.stubGlobal("fetch", fetchMock);
});

afterEach(() => {
  delete process.env.EBAY_CLIENT_ID;
  delete process.env.EBAY_CLIENT_SECRET;
  vi.unstubAllGlobals();
});

async function load() {
  return import("@/lib/ebay-parts");
}

describe("an app with no eBay credentials", () => {
  it("asks eBay nothing at all", async () => {
    delete process.env.EBAY_CLIENT_ID;
    delete process.env.EBAY_CLIENT_SECRET;
    const { searchEbayPartPhoto, isEbayConfigured } = await load();

    expect(isEbayConfigured()).toBe(false);
    expect(await searchEbayPartPhoto("84306-06140")).toBeNull();
    // Not "no photo found" — no request. This is the state the app ships in,
    // and it has to cost nothing.
    expect(fetchMock).not.toHaveBeenCalled();
  });
});

describe("minting the application token", () => {
  it("sends the credentials the way the grant flow asks for them", async () => {
    fetchMock
      .mockResolvedValueOnce(jsonResponse(TOKEN_BODY))
      .mockResolvedValueOnce(jsonResponse({ itemSummaries: [] }));

    const { searchEbayPartPhoto } = await load();
    await searchEbayPartPhoto("84306-06140");

    const [url, init] = fetchMock.mock.calls[0];
    expect(url).toBe("https://api.ebay.com/identity/v1/oauth2/token");
    expect(init.method).toBe("POST");
    expect(init.headers["Content-Type"]).toBe("application/x-www-form-urlencoded");
    // "Basic " + base64(id:secret), not the raw credentials.
    expect(init.headers.Authorization).toBe(`Basic ${btoa("test-id:test-secret")}`);
    expect(init.body).toContain("grant_type=client_credentials");
    expect(init.body).toContain(encodeURIComponent("https://api.ebay.com/oauth/api_scope"));
  });

  it("mints once and reuses it", async () => {
    fetchMock
      .mockResolvedValueOnce(jsonResponse(TOKEN_BODY))
      .mockResolvedValue(jsonResponse({ itemSummaries: [] }));

    const { searchEbayPartPhoto } = await load();
    await searchEbayPartPhoto("84306-06140");
    await searchEbayPartPhoto("89460-06020");
    await searchEbayPartPhoto("90919-02240");

    // eBay allows 1,000 grants a day against 5,000 searches. Minting per
    // lookup would exhaust the cheaper limit first and take the source down
    // with it.
    const mints = fetchMock.mock.calls.filter(([u]) =>
      String(u).includes("/identity/v1/oauth2/token")
    );
    expect(mints).toHaveLength(1);
    expect(fetchMock).toHaveBeenCalledTimes(4);
  });

  it("drops a token eBay has stopped accepting", async () => {
    fetchMock
      .mockResolvedValueOnce(jsonResponse(TOKEN_BODY))
      .mockResolvedValueOnce(jsonResponse({}, 401))
      .mockResolvedValueOnce(jsonResponse(TOKEN_BODY))
      .mockResolvedValueOnce(jsonResponse({ itemSummaries: [] }));

    const { searchEbayPartPhoto } = await load();
    expect(await searchEbayPartPhoto("84306-06140")).toBeNull();
    await searchEbayPartPhoto("84306-06140");

    // Otherwise a token that expired early costs an hour of silent misses.
    const mints = fetchMock.mock.calls.filter(([u]) =>
      String(u).includes("/identity/v1/oauth2/token")
    );
    expect(mints).toHaveLength(2);
  });

  it("says why when eBay refuses to mint one", async () => {
    const warn = vi.spyOn(console, "warn").mockImplementation(() => {});
    fetchMock.mockResolvedValueOnce(
      jsonResponse({ error: "invalid_client" }, 401)
    );

    const { searchEbayPartPhoto } = await load();
    expect(await searchEbayPartPhoto("84306-06140")).toBeNull();

    // An unaccepted licence agreement and a Sandbox keyset used against
    // production both look like "no photo" from the outside.
    expect(warn.mock.calls.flat().join(" ")).toContain("invalid_client");
    warn.mockRestore();
  });
});

describe("searching for the number", () => {
  beforeEach(() => {
    fetchMock.mockResolvedValueOnce(jsonResponse(TOKEN_BODY));
  });

  it("asks the right endpoint, as an application, on one marketplace", async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse({ itemSummaries: [] }));
    const { searchEbayPartPhoto } = await load();
    await searchEbayPartPhoto("84306-06140");

    const [url, init] = fetchMock.mock.calls[1];
    expect(url).toContain("https://api.ebay.com/buy/browse/v1/item_summary/search");
    expect(url).toContain(`q=${encodeURIComponent("84306-06140")}`);
    expect(init.headers.Authorization).toBe("Bearer v^1.1#token");
    expect(init.headers["X-EBAY-C-MARKETPLACE-ID"]).toBe("EBAY_US");
  });

  it("takes the first listing that quotes the number", async () => {
    fetchMock.mockResolvedValueOnce(
      jsonResponse({
        itemSummaries: [
          // Sold as a fit for the car, never naming the part it is.
          listing("Clock Spring Spiral Cable fits Toyota Camry 2007-2011"),
          listing("Genuine Toyota 84306-06140 Clock Spring", "https://i.ebayimg.com/right.jpg"),
        ],
      })
    );

    const { searchEbayPartPhoto } = await load();
    const photo = await searchEbayPartPhoto("84306-06140");

    expect(photo?.imageUrl).toBe("https://i.ebayimg.com/right.jpg");
    expect(photo?.listingUrl).toBe("https://www.ebay.com/itm/123456789");
  });

  it("answers nothing when no listing names the part number", async () => {
    fetchMock.mockResolvedValueOnce(
      jsonResponse({
        itemSummaries: [listing("Clock Spring for Toyota Camry"), listing("Airbag module")],
      })
    );

    // A seller who does not quote the number is not claiming to sell that
    // part, and the card keeps its drawing rather than a confident stranger.
    const { searchEbayPartPhoto } = await load();
    expect(await searchEbayPartPhoto("84306-06140")).toBeNull();
  });

  it("asks for the card's size, not the seller's full-size photograph", async () => {
    fetchMock.mockResolvedValueOnce(
      jsonResponse({
        itemSummaries: [listing("Toyota 84306-06140 clock spring", "https://i.ebayimg.com/s-l225.jpg")],
      })
    );

    // Rendered in a 190px box, on a phone connection, and a seller's original
    // is frequently a 2MB photograph off their phone. `search` often leaves
    // `thumbnailImages` empty, so the size is asked for in the URL rather than
    // hoped for in the payload.
    const { searchEbayPartPhoto } = await load();
    expect((await searchEbayPartPhoto("84306-06140"))?.imageUrl).toBe(
      "https://i.ebayimg.com/s-l400.jpg"
    );
  });

  it("strips eBay's campaign parameters off the photo", async () => {
    fetchMock.mockResolvedValueOnce(
      jsonResponse({
        itemSummaries: [
          listing(
            "Toyota 84306-06140 clock spring",
            "https://i.ebayimg.com/s-l225.jpg?utm_source=browse-api"
          ),
        ],
      })
    );

    const { searchEbayPartPhoto } = await load();
    expect((await searchEbayPartPhoto("84306-06140"))?.imageUrl).toBe(
      "https://i.ebayimg.com/s-l400.jpg"
    );
  });

  it("keeps quiet when a search fails", async () => {
    const warn = vi.spyOn(console, "warn").mockImplementation(() => {});
    fetchMock.mockResolvedValueOnce(jsonResponse({}, 500));

    // A missing photo is an ordinary outcome and never the reader's problem.
    const { searchEbayPartPhoto } = await load();
    expect(await searchEbayPartPhoto("84306-06140")).toBeNull();
    warn.mockRestore();
  });
});

describe("a number too short to be one", () => {
  it("never leaves the app", async () => {
    const { searchEbayPartPhoto } = await load();
    // "1234" will appear inside somebody else's part number. Refused before a
    // token is even minted, so a report full of blank OEM fields costs nothing.
    expect(await searchEbayPartPhoto("1234")).toBeNull();
    expect(await searchEbayPartPhoto("")).toBeNull();
    expect(fetchMock).not.toHaveBeenCalled();
  });
});

describe("the size of the photograph that actually gets sent", () => {
  it("asks eBay for the card's size rather than the seller's original", async () => {
    const { atCardSize } = await load();
    // 534KB against 49KB on a real listing, rendered in a 190px box, on the
    // phone connection this app is used on.
    expect(atCardSize("https://i.ebayimg.com/images/g/Z4w/s-l1600.jpg")).toBe(
      "https://i.ebayimg.com/images/g/Z4w/s-l400.jpg"
    );
    expect(atCardSize("https://i.ebayimg.com/images/g/g30/s-l1200.webp")).toBe(
      "https://i.ebayimg.com/images/g/g30/s-l400.webp"
    );
  });

  it("leaves a URL it does not recognise alone", async () => {
    // Guessing at a rewrite of something unrecognised is how a working photo
    // becomes a 404.
    const odd = "https://i.ebayimg.com/images/g/abc/picture.jpg";
    const { atCardSize } = await load();
    expect(atCardSize(odd)).toBe(odd);
  });
});
