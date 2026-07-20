import 'package:flutter/material.dart';
import '../data/models/news_article.dart';
import '../data/repositories/news_repository.dart';

class SearchProvider with ChangeNotifier {
  final NewsRepository _repository;

  SearchProvider({NewsRepository? repository}) : _repository = repository ?? NewsRepository();

  String _query = '';
  List<NewsArticle> _searchResults = [];
  int _page = 1;
  final int _pageSize = 15;

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

    if (isRefresh) {
      _page = 1;
      _hasMore = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.searchNews(
        query: _query,
        page: _page,
        pageSize: _pageSize,
      );

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
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _searchResults = [];
      _hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load next page of search results
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _query.trim().isEmpty) return;

    _isLoadingMore = true;
    _errorMessage = null;
    notifyListeners();

    _page++;

    try {
      final nextResults = await _repository.searchNews(
        query: _query,
        page: _page,
        pageSize: _pageSize,
      );

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
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _page--; // Rollback page on failure
    } finally {
      _isLoadingMore = false;
      notifyListeners();
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
}
