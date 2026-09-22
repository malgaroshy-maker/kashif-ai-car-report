import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dictionary_entry.dart';
import '../../data/repositories/dictionary_repository.dart';

class DictionaryState {
  final List<DictionaryEntry> entries;
  final List<String> categories;
  final String selectedCategory;
  final String searchQuery;
  final bool isLoading;

  DictionaryState({
    this.entries = const [],
    this.categories = const ['الكل'],
    this.selectedCategory = 'الكل',
    this.searchQuery = '',
    this.isLoading = false,
  });

  DictionaryState copyWith({
    List<DictionaryEntry>? entries,
    List<String>? categories,
    String? selectedCategory,
    String? searchQuery,
    bool? isLoading,
  }) {
    return DictionaryState(
      entries: entries ?? this.entries,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DictionaryNotifier extends StateNotifier<DictionaryState> {
  final DictionaryRepository _repository;

  DictionaryNotifier(this._repository) : super(DictionaryState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final cats = await _repository.getCategories();
    final entries = await _repository.getEntries();
    state = state.copyWith(
      isLoading: false,
      categories: cats,
      entries: entries,
    );
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query);
    final results = await _repository.search(query, category: state.selectedCategory);
    state = state.copyWith(entries: results);
  }

  Future<void> selectCategory(String category) async {
    state = state.copyWith(selectedCategory: category);
    final results = await _repository.search(state.searchQuery, category: category);
    state = state.copyWith(entries: results);
  }
}

final dictionaryRepositoryProvider = Provider((ref) => DictionaryRepository());

final dictionaryProvider = StateNotifierProvider<DictionaryNotifier, DictionaryState>((ref) {
  final repo = ref.watch(dictionaryRepositoryProvider);
  return DictionaryNotifier(repo);
});
