import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/dictionary_entry.dart';

class DictionaryRepository {
  List<DictionaryEntry> _cachedEntries = [];

  Future<List<DictionaryEntry>> getEntries() async {
    if (_cachedEntries.isNotEmpty) return _cachedEntries;
    try {
      final jsonString = await rootBundle.loadString('assets/data/dictionary.json');
      final List<dynamic> list = jsonDecode(jsonString);
      _cachedEntries = list.map((e) => DictionaryEntry.fromJson(e as Map<String, dynamic>)).toList();
      return _cachedEntries;
    } catch (e) {
      return [];
    }
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
