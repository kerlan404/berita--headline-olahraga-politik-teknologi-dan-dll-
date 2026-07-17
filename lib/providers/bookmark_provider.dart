import 'package:flutter/foundation.dart';
import '../data/models/news_article.dart';

class BookmarkProvider with ChangeNotifier {
  final Map<String, NewsArticle> _bookmarkedArticles = {};

  /// Returns list of bookmarked articles (newest first)
  List<NewsArticle> get bookmarkedArticles =>
      _bookmarkedArticles.values.toList().reversed.toList();

  /// Number of bookmarked articles
  int get count => _bookmarkedArticles.length;

  /// Check if an article is bookmarked by its URL
  bool isBookmarked(String url) => _bookmarkedArticles.containsKey(url);

  /// Toggle bookmark for an article
  void toggleBookmark(NewsArticle article) {
    if (_bookmarkedArticles.containsKey(article.url)) {
      _bookmarkedArticles.remove(article.url);
    } else {
      _bookmarkedArticles[article.url] = article;
    }
    notifyListeners();
  }

  /// Add bookmark (no-op if already bookmarked)
  void addBookmark(NewsArticle article) {
    if (!_bookmarkedArticles.containsKey(article.url)) {
      _bookmarkedArticles[article.url] = article;
      notifyListeners();
    }
  }

  /// Remove bookmark (no-op if not bookmarked)
  void removeBookmark(String url) {
    if (_bookmarkedArticles.containsKey(url)) {
      _bookmarkedArticles.remove(url);
      notifyListeners();
    }
  }

  /// Clear all bookmarks
  void clearAll() {
    if (_bookmarkedArticles.isNotEmpty) {
      _bookmarkedArticles.clear();
      notifyListeners();
    }
  }
}
