import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/route_transitions.dart';
import '../../providers/bookmark_provider.dart';
import '../../widgets/news_card.dart';
import '../detail/detail_screen.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TERSIMPAN',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        actions: [
          Consumer<BookmarkProvider>(
            builder: (context, provider, child) {
              if (provider.count == 0) return const SizedBox.shrink();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Count badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${provider.count}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    tooltip: 'Hapus Semua',
                    onPressed: () => _confirmClearAll(context, provider),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, provider, child) {
          final articles = provider.bookmarkedArticles;

          if (articles.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: articles.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final article = articles[index];
              return Dismissible(
                key: ValueKey(article.url),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryAccent.withValues(alpha: 0.0),
                        AppTheme.primaryAccent.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline_rounded, color: AppTheme.primaryAccent, size: 24),
                      SizedBox(height: 2),
                      Text(
                        'HAPUS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryAccent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                confirmDismiss: (_) => _confirmDismiss(context, provider, article.url),
                onDismissed: (_) {
                  // Already handled by confirmDismiss
                },
                child: NewsCard(
                  article: article,
                  onTap: () {
                    Navigator.of(context).push(
                      SlideRightRoute(page: DetailScreen(article: article)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.bookmark_rounded,
                size: 42,
                color: AppTheme.primaryAccent,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Artikel Tersimpan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap ikon hati ♥ pada berita untuk menyimpannya di sini.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDismiss(
    BuildContext context,
    BookmarkProvider provider,
    String url,
  ) async {
    final completer = Completer<bool>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Artikel dihapus dari tersimpan',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.surface,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'BATAL',
          textColor: AppTheme.primaryAccent,
          onPressed: () {
            completer.complete(false);
          },
        ),
      ),
    );

    // Remove bookmark only if user does NOT tap BATAL
    Future.delayed(const Duration(seconds: 3), () async {
      if (!completer.isCompleted) {
        await provider.removeBookmark(url);
        completer.complete(true);
      }
    });

    return completer.future;
  }

  void _confirmClearAll(BuildContext context, BookmarkProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.delete_sweep_outlined, color: AppTheme.primaryAccent, size: 22),
            SizedBox(width: 10),
            Text(
              'Hapus Semua',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Semua artikel tersimpan akan dihapus. Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                'Batal',
                style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await provider.clearAll();
              if (ctx.mounted) Navigator.pop(ctx);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Semua artikel dihapus'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.surface,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Hapus Semua',
                style: TextStyle(
                  color: AppTheme.primaryAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
