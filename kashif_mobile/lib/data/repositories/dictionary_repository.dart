import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/dictionary_entry.dart';
import '../storage/hive_storage.dart';

class DictionaryRepository {
  List<DictionaryEntry> _cachedBaseEntries = [];

  Future<List<DictionaryEntry>> getEntries() async {
    final customList = KashifStorage.customDictionaryEntries
        .map((e) => DictionaryEntry.fromJson(e))
        .toList();

    if (_cachedBaseEntries.isEmpty) {
      try {
        final jsonString = await rootBundle.loadString(
          'assets/data/dictionary.json',
        );
        final List<dynamic> list = jsonDecode(jsonString);
        _cachedBaseEntries = list
            .map((e) => DictionaryEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        _cachedBaseEntries = [];
      }
    }

    final customTerms = customList
        .map((c) => c.libyanTerm.trim().toLowerCase())
        .toSet();
    final nonDuplicateBase = _cachedBaseEntries.where(
      (b) => !customTerms.contains(b.libyanTerm.trim().toLowerCase()),
    );

    return [...customList, ...nonDuplicateBase];
  }

  Future<void> addCustomEntry(DictionaryEntry entry) async {
    await KashifStorage.saveCustomDictionaryEntry(entry.toJson());
  }

  Future<void> deleteCustomEntry(String libyanTerm) async {
    await KashifStorage.deleteCustomDictionaryEntry(libyanTerm);
  }

  Future<List<String>> getCategories() async {
    final entries = await getEntries();
    final set = <String>{};
    for (var e in entries) {
      if (e.category.isNotEmpty) set.add(e.category);
    }
    return ['الكل', ...set];
  }

  Future<List<DictionaryEntry>> search(String query, {String? category}) async {
    final entries = await getEntries();
    final cleanQuery = query.trim().toLowerCase();

    return entries.where((e) {
      if (category != null && category != 'الكل' && e.category != category) {
        return false;
      }
      if (cleanQuery.isEmpty) return true;

      return e.libyanTerm.toLowerCase().contains(cleanQuery) ||
          e.standardArabic.toLowerCase().contains(cleanQuery) ||
          e.english.toLowerCase().contains(cleanQuery);
    }).toList();
  }
}
