import '../models/spare_part.dart';
import '../models/vehicle_info.dart';
import '../storage/hive_storage.dart';
import '../../core/network/api_client.dart';
import 'vehicle_parts_catalog.dart';

/// Intelligent Universal OEM & Aftermarket Part Number Resolver.
/// Resolves authentic manufacturer part numbers across car makes & models
/// via local verified EPC catalog rules, cloud search grounding, and persistent cache.
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
    final cleanVin = (vehicle?.cleanVin.isNotEmpty == true && vehicle?.cleanVin != 'غير محدد' && vehicle!.cleanVin.length >= 11)
        ? vehicle.cleanVin.trim()
        : '';
    final oem = (part.oemPartNumber != null &&
            !part.oemPartNumber!.contains('VIN') &&
            !part.oemPartNumber!.contains('مطابقة') &&
            !part.oemPartNumber!.contains('حسب') &&
            !part.oemPartNumber!.contains('وكالة'))
        ? part.oemPartNumber!.trim()
        : '';

    // Direct targeted search query: opens exact part schematics, exploded diagrams, and OEM listings directly
    final queryWords = [car, pName, oem, 'OEM part number', cleanVin]
        .where((s) => s.isNotEmpty)
        .join(' ')
        .trim();
    return 'https://www.google.com/search?q=${Uri.encodeComponent(queryWords)}';
  }

  /// Generates a direct link to the vehicle's entire OEM parts catalog by make, model, year and VIN
  static String generateVehicleCatalogUrl({VehicleInfo? vehicle}) {
    final car = '${vehicle?.year ?? ""} ${vehicle?.make ?? ""} ${vehicle?.model ?? ""}'.trim();
    final cleanVin = (vehicle?.cleanVin.isNotEmpty == true && vehicle?.cleanVin != 'غير محدد' && vehicle!.cleanVin.length >= 11)
        ? vehicle.cleanVin.trim()
        : '';
    final queryWords = [car, cleanVin, 'OEM parts catalog diagrams schematics']
        .where((s) => s.isNotEmpty)
        .join(' ')
        .trim();
    return 'https://www.google.com/search?q=${Uri.encodeComponent(queryWords)}';
  }

  /// Synchronous enrichment: checks verified EPC local catalog first,
  /// then checks local persistent Hive cache, or sets clean VIN verification guidance.
  /// Corrects hallucinated or mismatched generational part numbers automatically.
  static SparePartItem enrich(
    SparePartItem part, {
    VehicleInfo? vehicle,
  }) {
    // 1. Primary Check: Verified Vehicle Parts Catalog
    final catalogMatch = VehiclePartsCatalog.resolve(vehicle: vehicle, part: part);
    if (catalogMatch != null) {
      return catalogMatch;
    }

    // 2. Check local persistent Hive cache
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
    final isDummyOem = rawOem.contains('123456') ||
        rawOem.contains('028100200') ||
        rawOem.contains('19456') ||
        rawOem.contains('4111') ||
        rawOem.contains('4112') ||
        rawOem.contains('2J000') ||
        rawOem.contains('2J700') ||
        rawOem.contains('2J001') ||
        rawOem.contains('2J002') ||
        RegExp(r'\b\d{5}-2J\d{3}\b').hasMatch(rawOem) ||
        rawOem.toLowerCase().contains('dummy') ||
        rawOem.toLowerCase().contains('fake') ||
        rawOem == '1234567';

    final isOemMissing = isDummyOem ||
        rawOem.isEmpty ||
        rawOem.toUpperCase() == 'N/A' ||
        rawOem == 'غير محدد' ||
        rawOem == 'غير متوفر' ||
        rawOem == 'null' ||
        rawOem.contains('حسب رقم الهيكل') ||
        rawOem.contains('أصلي وكالة') ||
        rawOem.contains('وكالة') ||
        rawOem.contains('مطابقة') ||
        rawOem.contains('VIN');

    // Clean up hallucinated sequential numbers in aftermarket replacements
    final cleanReplacements = part.aftermarketReplacements.map((r) {
      return r
          .replaceAll(RegExp(r'\b123456\d*\b'), '')
          .replaceAll(RegExp(r'\b028100200\d*\b'), '')
          .replaceAll(RegExp(r'\b411[12]\b'), '')
          .replaceAll(RegExp(r'\b19456[78]\b'), '')
          .trim();
    }).where((r) => r.isNotEmpty).toSet().toList();

    final searchUrl = part.catalogSearchUrl ??
        generateCatalogSearchUrl(vehicle: vehicle, part: part);

    if (isOemMissing) {
      return SparePartItem(
        id: part.id,
        relatedCode: part.relatedCode,
        partNameLibyan: part.partNameLibyan,
        partNameStandardArabic: part.partNameStandardArabic,
        partNameEnglish: part.partNameEnglish,
        oemPartNumber: 'مطابقة بالهيكل',
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
      aftermarketReplacements: cleanReplacements.isNotEmpty ? cleanReplacements : part.aftermarketReplacements,
      estimatedPriceRangeLYD: part.estimatedPriceRangeLYD,
      systemCategory: part.systemCategory,
      partImageUrl: part.partImageUrl,
      replacementUrgency: part.replacementUrgency,
      catalogSearchUrl: searchUrl,
      confidence: part.confidence ?? 'verified',
    );
  }

  /// Batch enrich a list of spare parts with catalog grounding and deduplication guard
  static List<SparePartItem> enrichList(
    List<SparePartItem> parts, {
    VehicleInfo? vehicle,
  }) {
    // 1. Pass through vehicle parts catalog enricher (handles related part dependencies)
    final catalogEnriched = VehiclePartsCatalog.enrichPartsList(vehicle: vehicle, parts: parts);

    final enrichedList = <SparePartItem>[];
    final seenOems = <String>{};

    for (int i = 0; i < catalogEnriched.length; i++) {
      final enriched = enrich(catalogEnriched[i], vehicle: vehicle);
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

    // 1. First enrich locally via verified catalog
    final locallyEnriched = enrichList(parts, vehicle: effectiveVehicle);

    // 2. Identify remaining unverified parts needing resolution
    final unverifiedParts = <SparePartItem>[];
    for (final p in locallyEnriched) {
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

    // 3. Query cloud resolver if needed
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

    // 4. Return enriched list from catalog, cache & deduplicated
    return enrichList(locallyEnriched, vehicle: effectiveVehicle);
  }
}
