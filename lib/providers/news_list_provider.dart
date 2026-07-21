import 'package:flutter/material.dart';
import '../data/models/news_article.dart';
import '../data/repositories/news_repository.dart';
import 'recent_activity_provider.dart';

class NewsListProvider with ChangeNotifier {
  final NewsRepository _repository;
  RecentActivityProvider? _recentActivity;

  NewsListProvider({NewsRepository? repository}) : _repository = repository ?? NewsRepository();

  /// Bind to RecentActivityProvider for read tracking
  void bindRecentActivity(RecentActivityProvider provider) {
    _recentActivity = provider;
  }

  /// Record article as recently read via the activity provider
  void recordRead(NewsArticle article) {
    _recentActivity?.recordRead(article);
  }

  String _currentCategory = 'all'; // Default category — Semua
  List<NewsArticle> _articles = [];
  int _page = 1;
  final int _pageSize = 15;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  // Last fetch timestamp for auto-refresh
  DateTime? _lastFetchTime;
  static const Duration _autoRefreshDuration = Duration(hours: 6);

  // Getters
  String get currentCategory => _currentCategory;
  List<NewsArticle> get articles => _articles;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  DateTime? get lastFetchTime => _lastFetchTime;

  /// Check if news should be auto-refreshed (more than 6 hours since last fetch)
  bool get needsRefresh {
    if (_lastFetchTime == null) return true;
    return DateTime.now().difference(_lastFetchTime!) > _autoRefreshDuration;
  }

  // Set category and trigger fetch
  void setCategory(String category) {
    if (_currentCategory == category) return;
    _currentCategory = category;
    fetchNews(isRefresh: true);
  }

  // Fetch initial or refreshed news
  Future<void> fetchNews({bool isRefresh = false}) async {
    if (isRefresh) {
      _page = 1;
      _hasMore = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newArticles = await _repository.getCategoryNews(
        category: _currentCategory,
        page: _page,
        pageSize: _pageSize,
      );

      if (isRefresh) {
        _articles = newArticles;
      } else {
        _articles.addAll(newArticles);
      }

      if (newArticles.length < _pageSize) {
        _hasMore = false;
      }
      
      _errorMessage = null;
      _lastFetchTime = DateTime.now();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _articles = [];
      _hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load next page of news
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    _errorMessage = null;
    notifyListeners();

    _page++;

    try {
      final nextArticles = await _repository.getCategoryNews(
        category: _currentCategory,
        page: _page,
        pageSize: _pageSize,
      );

      if (nextArticles.isEmpty) {
        _hasMore = false;
      } else {
        _articles.addAll(nextArticles);
        if (nextArticles.length < _pageSize) {
          _hasMore = false;
        }
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _page--; // Rollback page on failure
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
