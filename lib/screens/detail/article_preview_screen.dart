import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/route_transitions.dart';
import '../../data/models/news_article.dart';
import '../../widgets/bookmark_button.dart';
import 'detail_screen.dart';

class ArticlePreviewScreen extends StatelessWidget {
  final NewsArticle article;

  const ArticlePreviewScreen({
    super.key,
    required this.article,
  });

  void _openFullArticle(BuildContext context) {
    Navigator.of(context).push(
      SlideRightRoute(page: DetailScreen(article: article)),
    );
  }

  Future<void> _shareArticle() async {
    final text = '${article.title}\n\n${article.url}';
    await SharePlus.instance.share(
      ShareParams(text: text, subject: article.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = article.urlToImage != null && article.urlToImage!.isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero image
          SliverAppBar(
            expandedHeight: hasImage ? 340 : 120,
            pinned: true,
            backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.surfaceLight,
            leading: IconButton(
              icon: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.cardBgFor(isDark).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppTheme.dividerFor(isDark),
                    width: 1,
                  ),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Container(
                width: 38, height: 38,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: AppTheme.cardBgFor(isDark).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppTheme.dividerFor(isDark),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.share_rounded, size: 18),
                  tooltip: 'Bagikan',
                  onPressed: _shareArticle,
                  padding: EdgeInsets.zero,
                ),
              ),
              Container(
                width: 38, height: 38,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppTheme.cardBgFor(isDark).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppTheme.dividerFor(isDark),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: BookmarkButton(article: article, iconSize: 18),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            0.33, 0.33, 0.33, 0, 0,
                            0.33, 0.33, 0.33, 0, 0,
                            0.33, 0.33, 0.33, 0, 0,
                            0, 0, 0, 1, 0,
                          ]),
                          child: CachedNetworkImage(
                            imageUrl: article.urlToImage!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: AppTheme.cardBgFor(isDark)),
                            errorWidget: (_, __, ___) => Container(
                              color: AppTheme.cardBgFor(isDark),
                              child: const Icon(Icons.image_not_supported_rounded,
                                  size: 48, color: AppTheme.textSecondary),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0, right: 0, bottom: 0, height: 200,
                          child: IgnorePointer(child: Container(
                            decoration: BoxDecoration(gradient: LinearGradient(
                              begin: Alignment.bottomCenter, end: Alignment.topCenter,
                              colors: [
                                (isDark ? AppTheme.darkBackground : AppTheme.surfaceLight).withValues(alpha: 1.0),
                                (isDark ? AppTheme.darkBackground : AppTheme.surfaceLight).withValues(alpha: 0.7),
                                Colors.transparent,
                              ],
                            )),
                          )),
                        ),
                        Positioned(
                          left: 0, right: 0, top: 0, height: 80,
                          child: IgnorePointer(child: Container(
                            decoration: BoxDecoration(gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent],
                            )),
                          )),
                        ),
                        Positioned(
                          left: 16, bottom: 24,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            color: AppTheme.primaryContainer,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.source_rounded, size: 12, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(article.sourceName?.toUpperCase() ?? 'NEWS',
                                    style: AppTheme.labelBold.copyWith(
                                        fontSize: 10, color: Colors.white, letterSpacing: 1)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(color: AppTheme.cardBgFor(isDark)),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Text(article.title,
                      style: AppTheme.headlineLgMobile.copyWith(
                          color: AppTheme.textPrimaryFor(isDark), fontSize: 26)),
                  const SizedBox(height: 16),

                  // Meta
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainer.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            (article.author != null && article.author!.isNotEmpty)
                                ? article.author![0].toUpperCase() : 'N',
                            style: AppTheme.labelBold.copyWith(
                                color: AppTheme.primaryContainer, fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(article.author ?? 'Redaksi',
                                style: AppTheme.labelBold.copyWith(
                                    fontSize: 13, color: AppTheme.textPrimaryFor(isDark)),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.schedule_rounded, size: 11,
                                    color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.7)),
                                const SizedBox(width: 4),
                                Text(
                                    DateFormatter.getRelativeTime(article.publishedAt).toUpperCase(),
                                    style: AppTheme.labelSm.copyWith(
                                        fontSize: 10,
                                        color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.7))),
                                const SizedBox(width: 12),
                                Icon(Icons.timer_outlined, size: 11,
                                    color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.7)),
                                const SizedBox(width: 4),
                                Text('3 MENIT BACA',
                                    style: AppTheme.labelSm.copyWith(
                                        fontSize: 10,
                                        color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.7))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Source & Category chips
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.dividerFor(isDark).withValues(alpha: 0.5), width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.business_rounded, size: 12,
                                color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.7)),
                            const SizedBox(width: 6),
                            Text(article.sourceName ?? 'Sumber',
                                style: AppTheme.labelBold.copyWith(
                                    fontSize: 11, color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.8))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.category_rounded, size: 12,
                                color: AppTheme.primaryContainer.withValues(alpha: 0.7)),
                            const SizedBox(width: 6),
                            Text('HEADLINE',
                                style: AppTheme.labelBold.copyWith(
                                    fontSize: 11, color: AppTheme.primaryContainer.withValues(alpha: 0.8))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Accent divider
                  Container(height: 3, width: 48, color: AppTheme.primaryContainer),
                  const SizedBox(height: 20),

                  // Description
                  if (article.description != null && article.description!.isNotEmpty) ...[
                    Text('RINGKASAN BERITA',
                        style: AppTheme.labelBold.copyWith(
                            fontSize: 11, color: AppTheme.primaryContainer, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.dividerFor(isDark).withValues(alpha: 0.5), width: 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(article.description!,
                          style: AppTheme.bodyMd.copyWith(
                              fontSize: 14, color: AppTheme.textPrimaryFor(isDark))),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Content
                  if (article.content != null && article.content!.isNotEmpty) ...[
                    Text('ISI BERITA',
                        style: AppTheme.labelBold.copyWith(
                            fontSize: 11, color: AppTheme.textSecondaryFor(isDark), letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Text(article.content!,
                        style: AppTheme.bodyMd.copyWith(
                            fontSize: 13, color: AppTheme.textSecondaryFor(isDark))),
                    const SizedBox(height: 24),
                  ],

                  // Info panel
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.dividerFor(isDark).withValues(alpha: 0.5), width: 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 18,
                                color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.5)),
                            const SizedBox(width: 8),
                            Text('DETAIL ARTIKEL',
                                style: AppTheme.labelBold.copyWith(
                                    fontSize: 11, color: AppTheme.textSecondaryFor(isDark), letterSpacing: 0.8)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _infoRow(Icons.person_outline, 'Penulis', article.author ?? 'Tidak diketahui', isDark),
                        _infoRow(Icons.source_rounded, 'Sumber', article.sourceName ?? 'Tidak diketahui', isDark),
                        _infoRow(Icons.schedule_rounded, 'Publikasi', _formatDate(article.publishedAt), isDark),
                        _infoRow(Icons.timer_outlined, 'Estimasi baca', '3 menit', isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hint
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.primaryContainer.withValues(alpha: 0.2), width: 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.touch_app_rounded, size: 18,
                            color: AppTheme.primaryContainer),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ketuk "BACA LENGKAP" untuk melihat artikel di WebView.',
                            style: AppTheme.labelSm.copyWith(
                              fontSize: 11,
                              color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: AppTheme.cardBgFor(isDark).withValues(alpha: 0.95),
          border: Border(top: BorderSide(
            color: AppTheme.dividerFor(isDark).withValues(alpha: 0.5))),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openFullArticle(context),
            icon: const Icon(Icons.open_in_new_rounded, size: 20, color: Colors.white),
            label: Text('BACA LENGKAP',
                style: AppTheme.labelBold.copyWith(color: Colors.white, fontSize: 14, letterSpacing: 0.8)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14,
              color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(label,
                style: AppTheme.labelSm.copyWith(
                    fontSize: 11, color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.6))),
          ),
          Expanded(
            child: Text(value,
                style: AppTheme.labelBold.copyWith(
                    fontSize: 12, color: AppTheme.textPrimaryFor(isDark)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) { return dateStr; }
  }
}
