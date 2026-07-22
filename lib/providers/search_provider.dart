import 'package:flutter/material.dart';
import '../data/models/news_article.dart';
import '../data/repositories/news_repository.dart';
import 'recent_activity_provider.dart';

class SearchProvider with ChangeNotifier {
  final NewsRepository _repository;
  RecentActivityProvider? _recentActivity;

  SearchProvider({NewsRepository? repository}) : _repository = repository ?? NewsRepository();

  /// Bind to RecentActivityProvider for search history
  void bindRecentActivity(RecentActivityProvider provider) {
    _recentActivity = provider;
  }

  String _query = '';
  List<NewsArticle> _searchResults = [];
  int _page = 1;
  final int _pageSize = 15;
  int _requestId = 0; // #2 fix: cancel request basi

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  // Getters
  String get query => _query;
  List<NewsArticle> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  /// Search history (delegated to RecentActivityProvider)
  List<String> get searchHistory => _recentActivity?.searchHistory ?? [];

  // Perform search
  Future<void> search(String query, {bool isRefresh = false}) async {
    if (query.trim().isEmpty) {
      _query = '';
      _searchResults = [];
      _isLoading = false;
      _isLoadingMore = false;
      _hasMore = false;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _query = query;
    _requestId++; // #2 fix: cancel request basi saat query baru

    // Record search history on new search
    if (isRefresh) {
      _recentActivity?.addSearchQuery(query);
    }

    if (isRefresh) {
      _page = 1;
      _hasMore = true;
    }

    final currentRequestId = _requestId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.searchNews(
        query: _query,
        page: _page,
        pageSize: _pageSize,
      );

      // #2 fix: skip jika ada request yang lebih baru
      if (currentRequestId != _requestId) return;

      if (isRefresh) {
        _searchResults = results;
      } else {
        _searchResults.addAll(results);
      }

      if (results.length < _pageSize) {
        _hasMore = false;
      }

      _errorMessage = null;
    } catch (e) {
      if (currentRequestId != _requestId) return;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _searchResults = [];
      _hasMore = false;
    } finally {
      if (currentRequestId == _requestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Load next page of search results
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _query.trim().isEmpty) return;

    final currentRequestId = _requestId;
    _isLoadingMore = true;
    _errorMessage = null;
    notifyListeners();

    final targetPage = _page + 1; // #2 fix: simpan target di variable

    try {
      final nextResults = await _repository.searchNews(
        query: _query,
        page: targetPage,
        pageSize: _pageSize,
      );

      // #2 fix: skip jika ada request yang lebih baru
      if (currentRequestId != _requestId) return;

      _page = targetPage;

      if (nextResults.isEmpty) {
        _hasMore = false;
      } else {
        _searchResults.addAll(nextResults);
        if (nextResults.length < _pageSize) {
          _hasMore = false;
        }
      }
      _errorMessage = null;
    } catch (e) {
      if (currentRequestId != _requestId) return;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      if (currentRequestId == _requestId) {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  // Clear query and results
  void clearSearch() {
    _query = '';
    _searchResults = [];
    _isLoading = false;
    _isLoadingMore = false;
    _hasMore = true;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear search history
  void clearHistory() {
    _recentActivity?.clearSearchHistory();
    notifyListeners();
  }
}
