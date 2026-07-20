import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/news_article.dart';

class LocalDatabaseService {
  static Database? _database;
  static const int _cacheTTL = 30 * 60 * 1000; // 30 minutes in milliseconds

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'reedsfeed_cache.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE category_cache (
            id TEXT PRIMARY KEY,
            category TEXT NOT NULL,
            page INTEGER NOT NULL,
            articles TEXT NOT NULL,
            cached_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE search_cache (
            id TEXT PRIMARY KEY,
            query TEXT NOT NULL,
            page INTEGER NOT NULL,
            articles TEXT NOT NULL,
            cached_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE bookmarks (
            url TEXT PRIMARY KEY,
            article TEXT NOT NULL,
            saved_at INTEGER NOT NULL
          )
        ''');
        // Index for faster category queries
        await db.execute(
          'CREATE INDEX idx_category ON category_cache(category)',
        );
        await db.execute(
          'CREATE INDEX idx_search ON search_cache(query)',
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  // Category News Cache
  // ──────────────────────────────────────────────

  /// Cache category news articles for a given category and page
  Future<void> cacheCategoryNews({
    required String category,
    required int page,
    required List<NewsArticle> articles,
  }) async {
    final db = await database;
    final id = 'cat_${category}_p$page';
    final articlesJson = json.encode(articles.map((a) => a.toJson()).toList());

    await db.insert(
      'category_cache',
      {
        'id': id,
        'category': category,
        'page': page,
        'articles': articlesJson,
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // When caching page 1, clear old pages for the same category
    if (page == 1) {
      await db.delete(
        'category_cache',
        where: 'category = ? AND page > 1',
        whereArgs: [category],
      );
    }
  }

  /// Get cached category news if available and not expired
  Future<List<NewsArticle>?> getCachedCategoryNews({
    required String category,
    required int page,
  }) async {
    final db = await database;
    final id = 'cat_${category}_p$page';

    final results = await db.query(
      'category_cache',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;

    final row = results.first;
    final cachedAt = row['cached_at'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Check if cache is still valid
    if (now - cachedAt > _cacheTTL) {
      return null; // Expired
    }

    final articlesJson = json.decode(row['articles'] as String) as List<dynamic>;
    return articlesJson.map((j) => NewsArticle.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// Get cached category news regardless of expiry (for offline fallback)
  Future<List<NewsArticle>?> getAnyCachedCategoryNews({
    required String category,
    required int page,
  }) async {
    final db = await database;
    final id = 'cat_${category}_p$page';

    final results = await db.query(
      'category_cache',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;

    final row = results.first;
    final articlesJson = json.decode(row['articles'] as String) as List<dynamic>;
    return articlesJson.map((j) => NewsArticle.fromJson(j as Map<String, dynamic>)).toList();
  }

  // ──────────────────────────────────────────────
  // Search Results Cache
  // ──────────────────────────────────────────────

  /// Cache search results for a given query and page
  Future<void> cacheSearchResults({
    required String query,
    required int page,
    required List<NewsArticle> articles,
  }) async {
    final db = await database;
    final id = 'search_${query}_p$page';
    final articlesJson = json.encode(articles.map((a) => a.toJson()).toList());

    await db.insert(
      'search_cache',
      {
        'id': id,
        'query': query,
        'page': page,
        'articles': articlesJson,
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // When caching page 1, clear old pages for the same query
    if (page == 1) {
      await db.delete(
        'search_cache',
        where: 'query = ? AND page > 1',
        whereArgs: [query],
      );
    }
  }

  /// Get cached search results if available and not expired
  Future<List<NewsArticle>?> getCachedSearchResults({
    required String query,
    required int page,
  }) async {
    final db = await database;
    final id = 'search_${query}_p$page';

    final results = await db.query(
      'search_cache',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;

    final row = results.first;
    final cachedAt = row['cached_at'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - cachedAt > _cacheTTL) {
      return null;
    }

    final articlesJson = json.decode(row['articles'] as String) as List<dynamic>;
    return articlesJson.map((j) => NewsArticle.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// Get cached search regardless of expiry (for offline fallback)
  Future<List<NewsArticle>?> getAnyCachedSearchResults({
    required String query,
    required int page,
  }) async {
    final db = await database;
    final id = 'search_${query}_p$page';

    final results = await db.query(
      'search_cache',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;

    final row = results.first;
    final articlesJson = json.decode(row['articles'] as String) as List<dynamic>;
    return articlesJson.map((j) => NewsArticle.fromJson(j as Map<String, dynamic>)).toList();
  }

  // ──────────────────────────────────────────────
  // Bookmark Persistence
  // ──────────────────────────────────────────────

  /// Save a bookmark to local database
  Future<void> saveBookmark(NewsArticle article) async {
    final db = await database;
    await db.insert(
      'bookmarks',
      {
        'url': article.url,
        'article': json.encode(article.toJson()),
        'saved_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Remove a bookmark from local database
  Future<void> removeBookmark(String url) async {
    final db = await database;
    await db.delete(
      'bookmarks',
      where: 'url = ?',
      whereArgs: [url],
    );
  }

  /// Load all bookmarks from local database
  Future<Map<String, NewsArticle>> loadBookmarks() async {
    final db = await database;
    final results = await db.query(
      'bookmarks',
      orderBy: 'saved_at DESC',
    );

    final bookmarks = <String, NewsArticle>{};
    for (final row in results) {
      final articleJson = json.decode(row['article'] as String) as Map<String, dynamic>;
      final article = NewsArticle.fromJson(articleJson);
      bookmarks[article.url] = article;
    }
    return bookmarks;
  }

  /// Get bookmark count
  Future<int> getBookmarkCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM bookmarks');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Clear all bookmarks
  Future<void> clearAllBookmarks() async {
    final db = await database;
    await db.delete('bookmarks');
  }

  // ──────────────────────────────────────────────
  // Maintenance
  // ──────────────────────────────────────────────

  /// Clear all expired cache entries
  Future<void> clearExpiredCache() async {
    final db = await database;
    final cutoff = DateTime.now().millisecondsSinceEpoch - _cacheTTL;

    await db.delete(
      'category_cache',
      where: 'cached_at < ?',
      whereArgs: [cutoff],
    );
    await db.delete(
      'search_cache',
      where: 'cached_at < ?',
      whereArgs: [cutoff],
    );
  }

  /// Clear all cache (but keep bookmarks)
  Future<void> clearAllCache() async {
    final db = await database;
    await db.delete('category_cache');
    await db.delete('search_cache');
  }
}
