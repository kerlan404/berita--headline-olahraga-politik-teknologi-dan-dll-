import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article_analysis.dart';

/// Cache untuk hasil analisis artikel.
///
/// Menyimpan hasil analisis ke SharedPreferences dengan key `analysis_<url>`.
/// TTL: 24 jam — setelah itu analisis akan di-refresh.
class AnalysisCacheService {
  static const String _prefix = 'analysis_';
  static const Duration _ttl = Duration(hours: 24);

  /// Simpan hasil analisis ke cache
  static Future<void> cacheAnalysis(
      String url, ArticleAnalysis analysis) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'data': analysis.toJson(),
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      };
      await prefs.setString('$_prefix$url', json.encode(data));
    } catch (_) {}
  }

  /// Ambil hasil analisis dari cache (null jika kadaluarsa atau tidak ada)
  static Future<ArticleAnalysis?> getCachedAnalysis(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefix$url');
      if (raw == null) return null;

      final data = json.decode(raw) as Map<String, dynamic>;
      final cachedAt = data['cached_at'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - cachedAt > _ttl.inMilliseconds) {
        await prefs.remove('$_prefix$url');
        return null;
      }

      return ArticleAnalysis.fromJson(
          data['data'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
