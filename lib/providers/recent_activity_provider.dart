import 'package:flutter/foundation.dart';
import '../data/models/news_article.dart';

class RecentActivityProvider with ChangeNotifier {
  static const int _maxRecentArticles = 20;
  static const int _maxSearchHistory = 10;

  final List<NewsArticle> _recentlyRead = [];
  final List<String> _searchHistory = [];

  /// Recently read articles (newest first)
  List<NewsArticle> get recentlyRead => List.unmodifiable(_recentlyRead);

  /// Search history keywords (newest first)
  List<String> get searchHistory => List.unmodifiable(_searchHistory);

  /// Record an article as recently read
  void recordRead(NewsArticle article) {
    _recentlyRead.removeWhere((a) => a.url == article.url);
    _recentlyRead.insert(0, article);
    if (_recentlyRead.length > _maxRecentArticles) {
      _recentlyRead.removeLast();
    }
    notifyListeners();
  }

  /// Add a search query to history
  void addSearchQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    _searchHistory.remove(trimmed);
    _searchHistory.insert(0, trimmed);
    if (_searchHistory.length > _maxSearchHistory) {
      _searchHistory.removeLast();
    }
    notifyListeners();
  }

  /// Clear search history
  void clearSearchHistory() {
    _searchHistory.clear();
    notifyListeners();
  }

  /// Clear all recent activity
  void clearAll() {
    _recentlyRead.clear();
    _searchHistory.clear();
    notifyListeners();
  }
}
