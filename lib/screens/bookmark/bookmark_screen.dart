import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/route_transitions.dart';
import '../../providers/bookmark_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/news_card.dart';
import '../detail/detail_screen.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ARTIKEL TERSIMPAN',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        actions: [
          Consumer<BookmarkProvider>(
            builder: (context, provider, child) {
              if (provider.count == 0) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: 'Hapus Semua',
                onPressed: () => _confirmClearAll(context, provider),
              );
            },
          ),
        ],
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, provider, child) {
          final articles = provider.bookmarkedArticles;

          if (articles.isEmpty) {
            return const EmptyState(
              title: 'Belum Ada Artikel Tersimpan',
              description:
                  'Tap ikon hati ♥ pada berita untuk menyimpannya di sini.',
              icon: Icons.bookmark_border,
            );
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
                    color: AppTheme.primaryAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: AppTheme.primaryAccent,
                    size: 28,
                  ),
                ),
                onDismissed: (_) {
                  provider.removeBookmark(article.url);
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

  void _confirmClearAll(BuildContext context, BookmarkProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.divider),
        ),
        title: const Text(
          'Hapus Semua',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'Hapus semua artikel tersimpan?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.pop(ctx);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: AppTheme.primaryAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
