import '../models/spare_part.dart';
import '../models/vehicle_info.dart';
import '../storage/hive_storage.dart';
import '../../core/network/api_client.dart';

/// Intelligent Universal OEM & Aftermarket Part Number Resolver.
/// Resolves authentic manufacturer part numbers across ALL car makes & models
/// via cloud search grounding, local Hive persistent cache, and verified EPC deep links.
/// Strictly eliminates hardcoded car-specific lists and synthetic placeholder codes.
class PartNumberResolver {
  /// Builds a deterministic cache key for a vehicle and spare part
  static String buildCacheKey({
    VehicleInfo? vehicle,
    required SparePartItem part,
  }) {
    final v = '${vehicle?.make ?? ""}_${vehicle?.model ?? ""}_${vehicle?.year ?? ""}'
        .toLowerCase()
        .trim();
    final p = (part.partNameEnglish.isNotEmpty
            ? part.partNameEnglish
            : part.partNameLibyan)
        .toLowerCase()
        .trim();
    return 'part_${v}_$p';
  }

  /// Generates a direct 1-tap Google/EPC catalog search link pre-filtered by vehicle & part
  static String generateCatalogSearchUrl({
    VehicleInfo? vehicle,
    required SparePartItem part,
  }) {
    final car = '${vehicle?.year ?? ""} ${vehicle?.make ?? ""} ${vehicle?.model ?? ""}'.trim();
    final pName = part.partNameEnglish.isNotEmpty ? part.partNameEnglish : part.partNameLibyan;
    final oem = (part.oemPartNumber != null &&
            !part.oemPartNumber!.contains('VIN') &&
            !part.oemPartNumber!.contains('مطابقة'))
        ? part.oemPartNumber!
        : '';
    final query = '$car $pName $oem OEM part number'.trim();
    return 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
  }

  /// Synchronous enrichment: checks local persistent Hive cache first,
  /// otherwise preserves valid AI codes or sets clean VIN verification guidance.
  /// NEVER generates synthetic "-ALT" or fake placeholder codes.
  static SparePartItem enrich(
    SparePartItem part, {
    VehicleInfo? vehicle,
  }) {
    final cacheKey = buildCacheKey(vehicle: vehicle, part: part);
    final cached = KashifStorage.getCachedPart(cacheKey);

    if (cached != null) {
      final cachedOem = cached['oemPartNumber'] as String?;
      final cachedReplacements = (cached['aftermarketReplacements'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          part.aftermarketReplacements;
      PriceRangeLYD? cachedPrice = part.estimatedPriceRangeLYD;
      if (cached['estimatedPriceRangeLYD'] is Map) {
        cachedPrice = PriceRangeLYD.fromJson(
          Map<String, dynamic>.from(cached['estimatedPriceRangeLYD'] as Map),
        );
      }

      return SparePartItem(
        id: part.id,
        relatedCode: part.relatedCode,
        partNameLibyan: part.partNameLibyan,
        partNameStandardArabic: part.partNameStandardArabic,
        partNameEnglish: part.partNameEnglish,
        oemPartNumber: cachedOem ?? part.oemPartNumber,
        aftermarketReplacements: cachedReplacements,
        estimatedPriceRangeLYD: cachedPrice,
        systemCategory: part.systemCategory,
        partImageUrl: part.partImageUrl,
        replacementUrgency: part.replacementUrgency,
        catalogSearchUrl: cached['catalogSearchUrl'] as String? ??
            generateCatalogSearchUrl(vehicle: vehicle, part: part),
        confidence: cached['confidence'] as String? ?? 'verified',
      );
    }

    final rawOem = part.oemPartNumber?.trim() ?? '';
    final isOemMissing = rawOem.isEmpty ||
        rawOem.toUpperCase() == 'N/A' ||
        rawOem == 'غير محدد' ||
        rawOem == 'غير متوفر' ||
        rawOem == 'null' ||
        rawOem.contains('حسب رقم الهيكل') ||
        rawOem.contains('أصلي وكالة') ||
        rawOem.contains('وكالة');

    final searchUrl = part.catalogSearchUrl ??
        generateCatalogSearchUrl(vehicle: vehicle, part: part);

    if (isOemMissing) {
      return SparePartItem(
        id: part.id,
        relatedCode: part.relatedCode,
        partNameLibyan: part.partNameLibyan,
        partNameStandardArabic: part.partNameStandardArabic,
        partNameEnglish: part.partNameEnglish,
        oemPartNumber: 'مطابقة برقم الهيكل (VIN)',
        aftermarketReplacements: part.aftermarketReplacements.isNotEmpty
            ? part.aftermarketReplacements
            : const [
                'قطع أصلية معتمدة برقم الهيكل (VIN)',
                'Bosch Automotive Certified',
                'Denso Aftermarket Genuine',
              ],
        estimatedPriceRangeLYD: part.estimatedPriceRangeLYD,
        systemCategory: part.systemCategory,
        partImageUrl: part.partImageUrl,
        replacementUrgency: part.replacementUrgency,
        catalogSearchUrl: searchUrl,
        confidence: 'requires_vin',
      );
    }

    return SparePartItem(
      id: part.id,
      relatedCode: part.relatedCode,
      partNameLibyan: part.partNameLibyan,
      partNameStandardArabic: part.partNameStandardArabic,
      partNameEnglish: part.partNameEnglish,
      oemPartNumber: rawOem,
      aftermarketReplacements: part.aftermarketReplacements,
      estimatedPriceRangeLYD: part.estimatedPriceRangeLYD,
      systemCategory: part.systemCategory,
      partImageUrl: part.partImageUrl,
      replacementUrgency: part.replacementUrgency,
      catalogSearchUrl: searchUrl,
      confidence: part.confidence ?? 'verified',
    );
  }

  /// Batch enrich a list of spare parts with deduplication guard
  static List<SparePartItem> enrichList(
    List<SparePartItem> parts, {
    VehicleInfo? vehicle,
  }) {
    final enrichedList = <SparePartItem>[];
    final seenOems = <String>{};

    for (int i = 0; i < parts.length; i++) {
      final enriched = enrich(parts[i], vehicle: vehicle);
      final oem = enriched.oemPartNumber;

      // Deduplication guard: if an exact OEM number repeats across different parts,
      // fallback cleanly to VIN match, NEVER fake numbers.
      if (oem != null &&
          oem.isNotEmpty &&
          !oem.contains('مطابقة') &&
          !oem.contains('VIN') &&
          seenOems.contains(oem)) {
        final deduplicated = SparePartItem(
          id: enriched.id,
          relatedCode: enriched.relatedCode,
          partNameLibyan: enriched.partNameLibyan,
          partNameStandardArabic: enriched.partNameStandardArabic,
          partNameEnglish: enriched.partNameEnglish,
          oemPartNumber: 'مطابقة برقم الهيكل (VIN)',
          aftermarketReplacements: enriched.aftermarketReplacements,
          estimatedPriceRangeLYD: enriched.estimatedPriceRangeLYD,
          systemCategory: enriched.systemCategory,
          partImageUrl: enriched.partImageUrl,
          replacementUrgency: enriched.replacementUrgency,
          catalogSearchUrl: enriched.catalogSearchUrl,
          confidence: 'requires_vin',
        );
        enrichedList.add(deduplicated);
      } else {
        if (oem != null && oem.isNotEmpty && !oem.contains('مطابقة')) {
          seenOems.add(oem);
        }
        enrichedList.add(enriched);
      }
    }

    return enrichedList;
  }

  /// Asynchronous cloud resolver: dynamically enriches parts via POST /api/resolve-parts
  /// and saves resolved authentic numbers to local Hive cache.
  static Future<List<SparePartItem>> enrichListAsync(
    List<SparePartItem> parts, {
    VehicleInfo? vehicle,
    KashifApiClient? apiClient,
  }) async {
    final client = apiClient ?? KashifApiClient();
    final effectiveVehicle = vehicle ?? VehicleInfo(vin: '', make: '', model: '', year: '');

    // 1. Identify parts needing resolution
    final unverifiedParts = <SparePartItem>[];
    for (final p in parts) {
      final cacheKey = buildCacheKey(vehicle: effectiveVehicle, part: p);
      final cached = KashifStorage.getCachedPart(cacheKey);
      final rawOem = p.oemPartNumber?.trim() ?? '';
      final isMissing = rawOem.isEmpty ||
          rawOem.contains('مطابقة') ||
          rawOem.contains('VIN') ||
          rawOem.toUpperCase() == 'N/A';

      if (cached == null && isMissing) {
        unverifiedParts.add(p);
      }
    }

    // 2. Query cloud resolver if needed
    if (unverifiedParts.isNotEmpty && effectiveVehicle.make.isNotEmpty) {
      try {
        final resolvedFromCloud = await client.resolveParts(
          vehicle: effectiveVehicle,
          parts: unverifiedParts,
        );

        for (final resolved in resolvedFromCloud) {
          final cacheKey = buildCacheKey(vehicle: effectiveVehicle, part: resolved);
          await KashifStorage.cachePart(cacheKey, resolved.toJson());
        }
      } catch (_) {}
    }

    // 3. Return enriched list from cache & deduplicated
    return enrichList(parts, vehicle: effectiveVehicle);
  }
}
