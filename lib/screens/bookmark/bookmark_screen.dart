import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/route_transitions.dart';
import '../../providers/bookmark_provider.dart';
import '../../data/models/news_article.dart';
import '../../core/utils/date_formatter.dart';
import '../../widgets/bookmark_button.dart';
import '../detail/detail_screen.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.bookmark_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'SAVED',
              style: AppTheme.headlineMd.copyWith(
                fontSize: 20,
                color: AppTheme.textPrimaryFor(isDark),
              ),
            ),
          ],
        ),
        actions: [
          Consumer<BookmarkProvider>(
            builder: (context, provider, child) {
              if (provider.count == 0) return const SizedBox.shrink();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${provider.count}',
                      style: AppTheme.labelBold.copyWith(
                        fontSize: 12,
                        color: AppTheme.primaryContainer,
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
            return _buildEmptyState(isDark);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Dismissible(
                key: ValueKey(article.url),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: AppTheme.primaryContainer.withValues(alpha: 0.2),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline_rounded,
                          color: AppTheme.primaryContainer, size: 24),
                      SizedBox(height: 2),
                      Text(
                        'HAPUS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryContainer,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                confirmDismiss: (_) => _confirmDismiss(context, provider, article.url),
                onDismissed: (_) {},
                child: _buildBookmarkCard(context, article, isDark),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBookmarkCard(BuildContext context, NewsArticle article, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBgFor(isDark),
        border: Border.all(
          color: AppTheme.dividerFor(isDark).withValues(alpha: 0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            SlideRightRoute(page: DetailScreen(article: article)),
          );
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: article.urlToImage != null && article.urlToImage!.isNotEmpty
                      ? ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            0.33, 0.33, 0.33, 0, 0,
                            0.33, 0.33, 0.33, 0, 0,
                            0.33, 0.33, 0.33, 0, 0,
                            0, 0, 0, 1, 0,
                          ]),
                          child: CachedNetworkImage(
                            imageUrl: article.urlToImage!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppTheme.cardBgFor(isDark),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppTheme.cardBgFor(isDark),
                              child: const Icon(Icons.broken_image,
                                  color: AppTheme.textSecondary),
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.cardBgFor(isDark),
                          child: const Icon(Icons.image_not_supported,
                              color: AppTheme.textSecondary),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  article.sourceName?.toUpperCase() ?? 'NEWS',
                                  style: AppTheme.labelBold.copyWith(
                                    fontSize: 10,
                                    color: AppTheme.primaryContainer,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              BookmarkButton(
                                article: article,
                                iconSize: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            article.title,
                            style: AppTheme.headlineMd.copyWith(
                              fontSize: 16,
                              color: AppTheme.textPrimaryFor(isDark),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Text(
                        DateFormatter.getRelativeTime(article.publishedAt).toUpperCase(),
                        style: AppTheme.labelSm.copyWith(
                          fontSize: 10,
                          color: AppTheme.textSecondaryFor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.primaryContainer.withValues(alpha: 0.2),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_rounded,
                    size: 48,
                    color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '0',
                    style: AppTheme.headlineMd.copyWith(
                      fontSize: 24,
                      color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'BENCH IS EMPTY',
              style: AppTheme.headlineMd.copyWith(
                fontSize: 22,
                color: AppTheme.textPrimaryFor(isDark),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap bookmark button on any article\nto save it here.',
              style: AppTheme.bodyMd.copyWith(
                fontSize: 14,
                color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.7),
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
        content: Text('Artikel dihapus dari tersimpan',
            style: TextStyle(
                color: AppTheme.textPrimaryFor(Theme.of(context).brightness == Brightness.dark))),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.cardBgFor(Theme.of(context).brightness == Brightness.dark),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'BATAL',
          textColor: AppTheme.primaryContainer,
          onPressed: () {
            completer.complete(false);
          },
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () async {
      if (!completer.isCompleted) {
        await provider.removeBookmark(url);
        completer.complete(true);
      }
    });

    return completer.future;
  }

  void _confirmClearAll(BuildContext context, BookmarkProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBgFor(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        title: Row(
          children: [
            const Icon(Icons.delete_sweep_outlined,
                color: AppTheme.primaryContainer, size: 22),
            const SizedBox(width: 10),
            Text(
              'Hapus Semua',
              style: AppTheme.headlineMd.copyWith(
                fontSize: 18,
                color: AppTheme.textPrimaryFor(isDark),
              ),
            ),
          ],
        ),
        content: Text(
          'Semua artikel tersimpan akan dihapus. Tindakan ini tidak dapat dibatalkan.',
          style: AppTheme.bodyMd.copyWith(
            fontSize: 14,
            color: AppTheme.textSecondaryFor(isDark),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: AppTheme.labelBold.copyWith(
                color: AppTheme.textSecondaryFor(isDark),
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
                  content: const Text('Semua bookmark berhasil dihapus'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.cardBgFor(isDark),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.primaryContainer,
              child: Text(
                'HAPUS SEMUA',
                style: AppTheme.labelBold.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
