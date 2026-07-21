class ApiConstants {
  static const String defaultBaseUrl = 'https://newsapi.org/v2';
  
  // 'Semua' is handled specially — it fetches from all categories
  static const String allCategory = 'Semua';
  
  static const Map<String, String> categoryMap = {
    'Semua': 'all',
    'Olahraga': 'sports',
    'Teknologi': 'technology',
    'Bisnis': 'business',
    'Hiburan': 'entertainment',
    'Kesehatan': 'health',
    'Politik': 'politics',
  };

  static List<String> get categories => categoryMap.keys.toList();

  /// Returns categories excluding 'Semua' for multi-fetch
  static List<String> get apiCategories {
    return categoryMap.entries
        .where((e) => e.key != 'Semua')
        .map((e) => e.value)
        .toList();
  }
}
