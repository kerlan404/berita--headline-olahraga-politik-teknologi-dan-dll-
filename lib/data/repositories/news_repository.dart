import 'package:flutter/foundation.dart' show debugPrint;
import '../models/news_article.dart';
import '../services/news_api_service.dart';
import '../services/local_database_service.dart';

class NewsRepository {
  final NewsApiService _apiService;
  final LocalDatabaseService _dbService;

  NewsRepository({
    NewsApiService? apiService,
    LocalDatabaseService? dbService,
  })  : _apiService = apiService ?? NewsApiService(),
        _dbService = dbService ?? LocalDatabaseService();

  /// Fetch category news with cache fallback.
  /// Tries API first. On network failure, falls back to cached data (even if expired).
  Future<List<NewsArticle>> getCategoryNews({
    required String category,
    required int page,
    required int pageSize,
  }) async {
    try {
      // Try API first (network-first strategy)
      final articles = await _apiService.fetchTopHeadlines(
        category: category,
        page: page,
        pageSize: pageSize,
      );

      // Cache successful response asynchronously if DB is available
      if (_dbService.isAvailable) {
        _cacheCategoryNews(category, page, articles);
      }

      return articles;
    } catch (e) {
      // Network failed — try cache fallback
      final cached = await _dbService.getAnyCachedCategoryNews(
        category: category,
        page: page,
      );
      if (cached != null && cached.isNotEmpty) {
        debugPrint('NewsRepository: Using cached data for $category (page $page)');
        return cached;
      }
      // No cache available either — rethrow
      rethrow;
    }
  }

  /// Search news with cache fallback.
  Future<List<NewsArticle>> searchNews({
    required String query,
    required int page,
    required int pageSize,
  }) async {
    try {
      if (query.trim().isEmpty) return [];

      final articles = await _apiService.searchNews(
        query: query,
        page: page,
        pageSize: pageSize,
      );

      // Cache successful response if DB is available
      if (_dbService.isAvailable) {
        _cacheSearchResults(query, page, articles);
      }

      return articles;
    } catch (e) {
      // Network failed — try cache fallback
      final cached = await _dbService.getAnyCachedSearchResults(
        query: query,
        page: page,
      );
      if (cached != null && cached.isNotEmpty) {
        debugPrint('NewsRepository: Using cached search for "$query" (page $page)');
        return cached;
      }
      rethrow;
    }
  }

  /// Cache category news in the background (fire-and-forget)
  Future<void> _cacheCategoryNews(
    String category,
    int page,
    List<NewsArticle> articles,
  ) async {
    await _dbService.cacheCategoryNews(
      category: category,
      page: page,
      articles: articles,
    );
  }

  /// Cache search results in the background (fire-and-forget)
  Future<void> _cacheSearchResults(
    String query,
    int page,
    List<NewsArticle> articles,
  ) async {
    await _dbService.cacheSearchResults(
      query: query,
      page: page,
      articles: articles,
    );
  }
}

class NewsException implements Exception {
  final String message;
  NewsException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends NewsException {
  NetworkException(super.message);
}

class ApiException extends NewsException {
  ApiException(super.message);
}
