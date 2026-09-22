class DictionaryEntry {
  final String libyanTerm;
  final String standardArabic;
  final String english;
  final String category;
  final String? partSearchTerm;

  DictionaryEntry({
    required this.libyanTerm,
    required this.standardArabic,
    required this.english,
    required this.category,
    this.partSearchTerm,
  });

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    return DictionaryEntry(
      libyanTerm: json['libyanTerm'] as String? ?? '',
      standardArabic: json['standardArabic'] as String? ?? '',
      english: json['english'] as String? ?? '',
      category: json['category'] as String? ?? 'عام',
      partSearchTerm: json['partSearchTerm'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'libyanTerm': libyanTerm,
        'standardArabic': standardArabic,
        'english': english,
        'category': category,
        'partSearchTerm': partSearchTerm,
      };
}
