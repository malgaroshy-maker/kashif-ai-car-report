/**
 * A part photograph found by its OEM number, from eBay's Browse API.
 *
 * Every other source in this app is searched by *name*, because Wikimedia is
 * an encyclopedia: asked for "84306-06140" it has nothing, and asked for
 * "Clock Spring" it has a photograph of an anniversary clock. A parts
 * catalogue is the only kind of source that can answer the question a report
 * actually asks, which is "what does the part with this number look like".
 *
 * Two things about that number are worth saying out loud, because they decide
 * how the answer is presented:
 *
 * **It is almost never off the scanner.** A diagnostic PDF holds fault codes,
 * not part numbers — the Camry report this was built for contains neither
 * "84306" nor the word "Part" anywhere in its text. The number on the card
 * comes from the assistant's own recall, which is why the card already says
 * so. A photograph keyed to it is a photograph of whatever part that number
 * really belongs to, which is not the same claim as "this is your part".
 *
 * **It is somebody's listing.** eBay licenses this content for "facilitating
 * your own or Your Users' use of eBay Services", so the photograph is shown
 * as what it is — an item for sale, linked to the listing it belongs to — and
 * never embedded into the exported offline file, which would be a permanent
 * copy of eBay Content rather than the "limited intermediate copy" the licence
 * allows. `export-report.ts` drops these before it embeds anything.
 *
 * Unconfigured is the normal state: without credentials this module answers
 * `null` for everything and the app behaves exactly as it did before.
 */

/** Where an application token is minted. Production, not Sandbox. */
const TOKEN_URL = "https://api.ebay.com/identity/v1/oauth2/token";

/** The only scope `item_summary/search` needs under a client-credentials grant. */
const SCOPE = "https://api.ebay.com/oauth/api_scope";

const SEARCH_URL = "https://api.ebay.com/buy/browse/v1/item_summary/search";

/**
 * The marketplace whose listings are searched.
 *
 * US rather than anywhere nearer Libya, because that is where the parts are
 * listed under their Japanese and American OEM numbers in English.
 */
const MARKETPLACE = "EBAY_US";

/** Enough listings that the number can be matched in a title; few enough to stay cheap. */
const LIMIT = 10;

/** The photo is decoration on a card, not the report. It never delays it long. */
const TIMEOUT_MS = 5000;

export interface EbayPartPhoto {
  /** The listing's own photograph, served from i.ebayimg.com. */
  imageUrl: string;
  /** The listing it belongs to. The card links to it; the licence expects that. */
  listingUrl: string;
  /** The listing title, for the card's tooltip and for debugging a bad match. */
  title: string;
}

interface TokenResponse {
  access_token?: string;
  expires_in?: number;
}

interface ItemSummary {
  title?: string;
  itemWebUrl?: string;
  image?: { imageUrl?: string };
  thumbnailImages?: { imageUrl?: string }[];
}

interface SearchResponse {
  itemSummaries?: ItemSummary[];
}

/**
 * Credentials, or `null` when this source is simply not configured.
 *
 * Read at call time rather than at module load: `next build` evaluates modules
 * without the Worker's secrets bound, and a module that decided it was
 * unconfigured then would stay that way for the life of the deployment.
 */
function credentials(): { id: string; secret: string } | null {
  const id = process.env.EBAY_CLIENT_ID?.trim();
  const secret = process.env.EBAY_CLIENT_SECRET?.trim();
  return id && secret ? { id, secret } : null;
}

/** True when a report can be answered from eBay at all. */
export function isEbayConfigured(): boolean {
  return credentials() !== null;
}

/**
 * The application token, minted at most once per isolate per two hours.
 *
 * eBay allows 1,000 client-credentials grants a day against 5,000 searches, so
 * minting one per lookup would exhaust the cheaper limit first and take the
 * whole source down with it. The token itself lasts two hours; this keeps it
 * for slightly less, so a request never starts with a token that expires
 * mid-flight.
 *
 * The cache lives and dies with the isolate, like the photo cache next door.
 * What actually spares eBay the traffic is the CDN in front of
 * /api/parts-image, which answers most of these without reaching the Worker.
 */
let cachedToken: { value: string; expiresAt: number } | null = null;

/** A minute of headroom, so a token cannot expire between mint and use. */
const TOKEN_SAFETY_MS = 60_000;

async function applicationToken(): Promise<string> {
  const creds = credentials();
  if (!creds) return "";

  if (cachedToken && Date.now() < cachedToken.expiresAt) return cachedToken.value;

  const res = await fetch(TOKEN_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      Authorization: `Basic ${btoa(`${creds.id}:${creds.secret}`)}`,
    },
    body: `grant_type=client_credentials&scope=${encodeURIComponent(SCOPE)}`,
    signal: AbortSignal.timeout(TIMEOUT_MS),
  });

  if (!res.ok) {
    // The body carries eBay's own reason — an unaccepted licence agreement, a
    // Sandbox keyset used against production — and it is worth having in the
    // log, because every symptom of it looks like "no photo" from the outside.
    console.warn(
      `[ebay] could not mint a token: ${res.status} ${(await res.text()).slice(0, 200)}`
    );
    return "";
  }

  const data = (await res.json()) as TokenResponse;
  if (!data.access_token) return "";

  cachedToken = {
    value: data.access_token,
    expiresAt: Date.now() + (data.expires_in ?? 7200) * 1000 - TOKEN_SAFETY_MS,
  };
  return cachedToken.value;
}

/**
 * A part number with everything that is only punctuation taken out.
 *
 * Toyota writes "84306-06140", a seller writes "8430606140", "84306 06140" or
 * "Toyota 84306-06140 OEM". Compared without its separators, all four are the
 * same number, and none of them is the same number as a different part.
 */
export function normalizeOem(oem: string): string {
  return oem.replace(/[^a-z0-9]/gi, "").toUpperCase();
}

/**
 * Does this listing actually sell the part that was asked for?
 *
 * This is the one place in the whole photo pipeline where relevance can be
 * *proved* rather than argued: a part number is exact, and a seller who quotes
 * it in the title is claiming to sell that part. Every other source is judged
 * by rules over words, which is why those rules keep needing another exception
 * written into them.
 *
 * Short numbers are refused outright. Four characters is not a part number, it
 * is a fragment, and it will appear inside somebody else's.
 */
const MIN_OEM_LENGTH = 6;

export function listingMatchesOem(title: string, oem: string): boolean {
  const wanted = normalizeOem(oem);
  if (wanted.length < MIN_OEM_LENGTH) return false;
  return normalizeOem(title).includes(wanted);
}

/**
 * The first listing whose title quotes this OEM number, and its photograph.
 *
 * Returns `null` for "not configured", "nothing found" and "found nothing that
 * quotes the number" alike — all three mean the card keeps whatever it had.
 */
export async function searchEbayPartPhoto(
  oem: string
): Promise<EbayPartPhoto | null> {
  if (normalizeOem(oem).length < MIN_OEM_LENGTH) return null;

  try {
    const token = await applicationToken();
    if (!token) return null;

    const url = `${SEARCH_URL}?q=${encodeURIComponent(oem)}&limit=${LIMIT}`;
    const res = await fetch(url, {
      headers: {
        Authorization: `Bearer ${token}`,
        "X-EBAY-C-MARKETPLACE-ID": MARKETPLACE,
      },
      signal: AbortSignal.timeout(TIMEOUT_MS),
    });

    if (!res.ok) {
      // A 401 here means the cached token went stale early. Dropping it costs
      // one mint on the next call rather than an hour of silent misses.
      if (res.status === 401) cachedToken = null;
      console.warn(`[ebay] search failed: ${res.status}`);
      return null;
    }

    const data = (await res.json()) as SearchResponse;

    for (const item of data.itemSummaries ?? []) {
      const title = item.title ?? "";
      if (!listingMatchesOem(title, oem)) continue;

      // The gallery thumbnail before the full-size image: this is rendered in
      // a 190px box, and a seller's original is frequently a 2MB phone
      // photograph on the connection this app is actually used on.
      const imageUrl =
        item.thumbnailImages?.[0]?.imageUrl || item.image?.imageUrl || "";
      const listingUrl = item.itemWebUrl ?? "";
      if (!imageUrl || !listingUrl) continue;

      // eBay appends its own campaign parameters to both.
      return {
        imageUrl: imageUrl.split("?")[0],
        listingUrl,
        title,
      };
    }
  } catch (error) {
    // A missing photo is an ordinary outcome and never the user's problem.
    console.warn("[ebay] lookup failed:", error);
  }

  return null;
}
