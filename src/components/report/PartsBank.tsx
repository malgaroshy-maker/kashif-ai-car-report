"use client";

import * as React from "react";
import { Cell, CodePlate, Field } from "@/components/ui/primitives";
import { getPartSvg } from "@/lib/part-visuals";
import type { SparePartItem } from "@/lib/types";

/**
 * The parts list: what to buy, and what to say at the counter.
 *
 * Two things carry the weight here and both are stamped, not styled: the OEM
 * number, because somebody reads it aloud in a shop on شارع الرابش, and the
 * Libyan name, because that is what the counter actually understands. The
 * English name is present for cross-referencing a catalogue and is set small.
 *
 * A price the scan did not give is absent. The version this replaces printed
 * a 50–200 LYD range for parts nobody had priced.
 */
export function PartsBank({
  parts,
  selectedPartId,
  vehicle,
}: {
  parts: SparePartItem[];
  selectedPartId?: string;
  vehicle?: { make?: string; model?: string; year?: string | number };
}) {
  if (parts.length === 0) return null;

  return (
    <section
      id="spare-parts-section"
      className="space-y-[var(--s3)]"
      aria-labelledby="parts-heading"
    >
      <div className="rib-heavy flex items-center gap-[var(--s2)] pt-[var(--s2)]">
        <h2 id="parts-heading" className="k-bank uppercase text-(color:--ink)">
          قطع الغيار المطلوبة
        </h2>
        <span className="rib mt-[2px] h-px flex-1" aria-hidden />
        <span data-num className="k-label">
          {parts.length}
        </span>
      </div>

      <div className="grid gap-[var(--s3)] lg:grid-cols-2">
        {parts.map((part) => (
          <PartCell
            key={part.id}
            part={part}
            selected={part.id === selectedPartId}
            vehicle={vehicle}
          />
        ))}
      </div>
    </section>
  );
}

function PartCell({
  part,
  selected,
  vehicle,
}: {
  part: SparePartItem;
  selected: boolean;
  vehicle?: { make?: string; model?: string; year?: string | number };
}) {
  const photo = usePartPhoto(part, vehicle);
  const price = part.estimatedPriceRangeLYD;

  return (
    <Cell
      as="article"
      id={`part-${part.id}`}
      lifted={selected}
      className="p-[var(--s4)] scroll-mt-[var(--s8)]"
    >
      <div className="flex items-start gap-[var(--s3)]">
        <PartVisual part={part} photo={photo} />

        <div className="min-w-0 flex-1">
          <h3 className="font-bold leading-snug text-(color:--ink)">
            {part.partNameLibyan}
          </h3>
          {part.partNameEnglish && (
            <p data-num className="k-label normal-case">
              {part.partNameEnglish}
            </p>
          )}
          {part.relatedCode && (
            <div className="mt-[var(--s2)]">
              <CodePlate>{part.relatedCode}</CodePlate>
            </div>
          )}
        </div>
      </div>

      <dl className="rib mt-[var(--s3)] grid grid-cols-2 gap-x-[var(--s4)] pt-[var(--s2)]">
        <Field pair label="رقم الوكالة (OEM)" value={part.oemPartNumber} mono />
        <Field
          pair
          label="السعر التقديري"
          value={price ? `${price.min} – ${price.max} د.ل` : null}
          mono
        />
      </dl>

      {price?.marketNote && (
        <p className="k-label mt-[var(--s2)] normal-case">{price.marketNote}</p>
      )}

      {part.aftermarketReplacements.length > 0 && (
        <div className="mt-[var(--s3)]">
          <div className="k-label uppercase">بدائل معتمدة</div>
          <ul className="mt-[var(--s1)] flex flex-wrap gap-[var(--s2)]">
            {part.aftermarketReplacements.map((alt, i) => (
              <li key={i}>
                <span className="border border-[var(--rib)] px-[var(--s2)] py-[2px] text-(color:--ink-2)">
                  {alt}
                </span>
              </li>
            ))}
          </ul>
        </div>
      )}
    </Cell>
  );
}

/**
 * The part's picture: a photo when one is found, the drawn schematic until
 * then, and the schematic permanently if none is.
 *
 * The schematic is the honest default rather than a placeholder. It names the
 * part unambiguously without claiming to be a photograph of this car's part.
 */
function PartVisual({
  part,
  photo,
}: {
  part: SparePartItem;
  photo: { url: string; loading: boolean };
}) {
  const [failed, setFailed] = React.useState(false);
  const showPhoto = photo.url && !failed;

  return (
    <div
      className="grid h-[72px] w-[72px] shrink-0 place-items-center border border-[var(--rib)] bg-[var(--board-sunk)] p-[var(--s1)]"
      aria-hidden
    >
      {showPhoto ? (
        // The remote hosts are pinned by part-image-hosts.ts and the CSP, and
        // these are lazy thumbnails on a Worker with no image optimiser.
        // eslint-disable-next-line @next/next/no-img-element
        <img
          src={photo.url}
          alt=""
          loading="lazy"
          referrerPolicy="no-referrer"
          onError={() => setFailed(true)}
          className="h-full w-full object-contain"
        />
      ) : (
        <div
          className="h-full w-full [&_svg]:h-full [&_svg]:w-full"
          dangerouslySetInnerHTML={{
            __html: getPartSvg(
              part.partNameEnglish || part.partNameLibyan,
              part.oemPartNumber ?? ""
            ),
          }}
        />
      )}
    </div>
  );
}

/**
 * Looks up a photo after the report has rendered.
 *
 * Never on the analyse path: that search used to run for every part before the
 * diagnosis came back, which is most of why a report took ~41s (plan.md F28).
 */
function usePartPhoto(
  part: SparePartItem,
  vehicle?: { make?: string; model?: string; year?: string | number }
) {
  const supplied =
    part.partImageUrl?.startsWith("https://") &&
    !part.partImageUrl.includes("/parts/")
      ? part.partImageUrl
      : "";

  // One piece of state: what the lookup came back with. `undefined` means it
  // has not answered yet, and `""` means it answered "no photo" — which is a
  // settled result, not a pending one.
  //
  // Storing a separate `loading` flag meant setting it inside the effect
  // before the fetch, which is a synchronous setState in an effect body and an
  // extra render on every card. Deriving it needs neither.
  const [fetched, setFetched] = React.useState<string | undefined>(undefined);

  const make = vehicle?.make ?? "";
  const model = vehicle?.model ?? "";
  const year = String(vehicle?.year ?? "");
  const oem = part.oemPartNumber ?? "";
  const name = part.partNameEnglish || part.partNameLibyan;

  React.useEffect(() => {
    if (supplied) return;
    const controller = new AbortController();

    const params = new URLSearchParams({ make, model, year, oem, partName: name });
    fetch(`/api/parts-image?${params}`, {
      signal: AbortSignal.any([controller.signal, AbortSignal.timeout(15_000)]),
    })
      .then((r) => (r.ok ? r.json() : null))
      .then((d: { imageUrl?: string | null } | null) =>
        setFetched(d?.imageUrl ?? "")
      )
      .catch(() => {
        // No photo is an ordinary outcome. The schematic already names the
        // part, so the card is complete without one.
        if (!controller.signal.aborted) setFetched("");
      });

    return () => controller.abort();
  }, [supplied, make, model, year, oem, name]);

  return {
    url: supplied || fetched || "",
    loading: !supplied && fetched === undefined,
  };
}
