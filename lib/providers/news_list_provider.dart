import 'package:flutter/material.dart';
import '../data/models/news_article.dart';
import '../data/repositories/news_repository.dart';

class NewsListProvider with ChangeNotifier {
  final NewsRepository _repository;

  NewsListProvider({NewsRepository? repository}) : _repository = repository ?? NewsRepository();

  String _currentCategory = 'sports'; // Default category mapping to sports
  List<NewsArticle> _articles = [];
  int _page = 1;
  final int _pageSize = 5; // Simulating small page size to test pagination

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  // Getters
  String get currentCategory => _currentCategory;
  List<NewsArticle> get articles => _articles;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

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
