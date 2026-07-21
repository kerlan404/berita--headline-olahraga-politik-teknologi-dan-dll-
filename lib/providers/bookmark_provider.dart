import 'package:flutter/foundation.dart';
import '../data/models/news_article.dart';
import '../data/services/local_database_service.dart';

class BookmarkProvider with ChangeNotifier {
  final LocalDatabaseService _dbService;
  final Map<String, NewsArticle> _bookmarkedArticles = {};
  bool _isLoaded = false;

  BookmarkProvider({LocalDatabaseService? dbService})
      : _dbService = dbService ?? LocalDatabaseService();

  /// Returns list of bookmarked articles (newest first)
  List<NewsArticle> get bookmarkedArticles =>
      _bookmarkedArticles.values.toList().reversed.toList();

  /// Number of bookmarked articles
  int get count => _bookmarkedArticles.length;

  /// Whether bookmarks have been loaded from database
  bool get isLoaded => _isLoaded;

  /// Load bookmarks from local database
  Future<void> loadFromDatabase() async {
    try {
      final bookmarks = await _dbService.loadBookmarks();
      _bookmarkedArticles.clear();
      _bookmarkedArticles.addAll(bookmarks);
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('BookmarkProvider: Failed to load bookmarks: $e');
      _isLoaded = true;
    }
  }

  /// Check if an article is bookmarked by its URL
  bool isBookmarked(String url) => _bookmarkedArticles.containsKey(url);

  /// Toggle bookmark for an article
  Future<void> toggleBookmark(NewsArticle article) async {
    if (_bookmarkedArticles.containsKey(article.url)) {
      _bookmarkedArticles.remove(article.url);
      await _dbService.removeBookmark(article.url);
    } else {
      _bookmarkedArticles[article.url] = article;
      await _dbService.saveBookmark(article);
    }
    notifyListeners();
  }

  /// Add bookmark (no-op if already bookmarked)
  Future<void> addBookmark(NewsArticle article) async {
    if (!_bookmarkedArticles.containsKey(article.url)) {
      _bookmarkedArticles[article.url] = article;
      await _dbService.saveBookmark(article);
      notifyListeners();
    }
  }

  /// Remove bookmark (no-op if not bookmarked)
  Future<void> removeBookmark(String url) async {
    if (_bookmarkedArticles.containsKey(url)) {
      _bookmarkedArticles.remove(url);
      await _dbService.removeBookmark(url);
      notifyListeners();
    }
  }

  /// Clear all bookmarks
  Future<void> clearAll() async {
    if (_bookmarkedArticles.isNotEmpty) {
      _bookmarkedArticles.clear();
      await _dbService.clearAllBookmarks();
      notifyListeners();
    }
  }
}
