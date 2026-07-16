import '../models/news_article.dart';
import '../services/news_api_service.dart';

class NewsRepository {
  final NewsApiService _apiService;

  NewsRepository({NewsApiService? apiService}) : _apiService = apiService ?? NewsApiService();

  Future<List<NewsArticle>> getCategoryNews({
    required String category,
    required int page,
    required int pageSize,
  }) async {
    try {
      return await _apiService.fetchTopHeadlines(
        category: category,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      _handleException(e);
      rethrow;
    }
  }

  Future<List<NewsArticle>> searchNews({
    required String query,
    required int page,
    required int pageSize,
  }) async {
    try {
      if (query.trim().isEmpty) return [];
      return await _apiService.searchNews(
        query: query,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      _handleException(e);
      rethrow;
    }
  }

  void _handleException(dynamic e) {
    // Standardized log output
    print('NewsRepository Error: $e');
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
