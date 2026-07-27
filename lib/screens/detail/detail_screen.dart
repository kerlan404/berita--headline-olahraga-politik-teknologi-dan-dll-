import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/article_analysis.dart';
import '../../data/models/news_article.dart';
import '../../data/services/article_analysis_service.dart';
import '../../widgets/bookmark_button.dart';

class DetailScreen extends StatefulWidget {
  final NewsArticle article;

  const DetailScreen({
    super.key,
    required this.article,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ArticleAnalysisService _analysisService = ArticleAnalysisService();
  ArticleAnalysis? _analysis;
  bool _isAnalyzing = false;
  bool _analysisError = false;

  WebViewController? _controller;
  int _progress = 0;
  bool _isError = false;
  bool _showWebView = false;
  bool _hasOpenedArticle = false;

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    setState(() { _isAnalyzing = true; _analysisError = false; });
    try {
      final result = await _analysisService.analyze(widget.article);
      if (mounted) setState(() { _analysis = result; _isAnalyzing = false; });
    } catch (e) {
      if (mounted) setState(() { _analysisError = true; _isAnalyzing = false; });
    }
  }

  void _initWebView() {
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(NavigationDelegate(
          onProgress: (p) { if (mounted) setState(() => _progress = p); },
          onPageStarted: (_) { if (mounted) setState(() { _progress = 0; _isError = false; }); },
          onPageFinished: (_) { if (mounted) setState(() => _progress = 100); },
          onWebResourceError: (e) { if (mounted) setState(() => _isError = true); },
        ))
        ..loadRequest(Uri.parse(widget.article.url));
    } catch (e) {
      if (mounted) setState(() => _isError = true);
    }
  }

  Future<void> _shareArticle() async {
    await SharePlus.instance.share(
      ShareParams(text: '${widget.article.title}\n\n${widget.article.url}', subject: widget.article.title),
    );
  }

  Future<void> _openInBrowser() async {
    try {
      await launchUrl(Uri.parse(widget.article.url), mode: LaunchMode.externalApplication);
      if (mounted) setState(() => _hasOpenedArticle = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal membuka browser: $e'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = widget.article.urlToImage != null && widget.article.urlToImage!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.bodyMd.copyWith(fontSize: 15, color: AppTheme.textPrimaryFor(isDark)),
        ),
        actions: [
          if (!kIsWeb && !_isError)
            IconButton(
              icon: Icon(_showWebView ? Icons.article_rounded : Icons.web_rounded),
              tooltip: _showWebView ? 'Lihat Ringkasan' : 'Buka WebView',
              onPressed: () {
                if (_controller == null) _initWebView();
                setState(() => _showWebView = !_showWebView);
              },
            ),
          BookmarkButton(article: widget.article, iconSize: 22),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Bagikan Berita',
            onPressed: _shareArticle,
          ),
        ],
        bottom: !kIsWeb && _showWebView && _progress < 100 && !_isError
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: _progress / 100.0,
                  backgroundColor: AppTheme.darkBackground,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryContainer),
                  minHeight: 2,
                ),
              )
            : null,
      ),
      body: _showWebView && !kIsWeb && !_isError
          ? _buildWebViewBody()
          : _buildArticleContent(hasImage, isDark),
      bottomNavigationBar: _buildBottomBar(isDark),
    );
  }

  Widget _buildWebViewBody() {
    return Stack(
      children: [
        if (_controller != null) WebViewWidget(controller: _controller!),
        if (_isError || _controller == null) _buildWebError(isDark: true),
      ],
    );
  }

  Widget _buildWebError({required bool isDark}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.signal_wifi_off_rounded, size: 64, color: AppTheme.primaryContainer),
          const SizedBox(height: 16),
          Text('HALAMAN GAGAL DIMUAT',
              style: AppTheme.headlineMd.copyWith(color: AppTheme.textPrimaryFor(isDark), fontSize: 18)),
          const SizedBox(height: 8),
          Text('Ada masalah saat memuat halaman web. Silakan coba lagi.',
              style: AppTheme.bodyMd.copyWith(fontSize: 14, color: AppTheme.textSecondaryFor(isDark)),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () { setState(() { _isError = false; }); _initWebView(); },
            icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
            label: Text('MUAT ULANG', style: AppTheme.labelBold.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleContent(bool hasImage, bool isDark) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Hero image with grayscale
        SliverAppBar(
          expandedHeight: hasImage ? 300 : 100,
          pinned: true,
          backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.surfaceLight,
          leading: const SizedBox.shrink(),
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
                          imageUrl: widget.article.urlToImage!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppTheme.cardBgFor(isDark),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppTheme.cardBgFor(isDark),
                            child: const Icon(Icons.image_not_supported_rounded,
                                size: 48, color: AppTheme.textSecondary),
                          ),
                        ),
                      ),
                      // Bottom gradient
                      Positioned(
                        left: 0, right: 0, bottom: 0, height: 160,
                        child: IgnorePointer(child: Container(
                          decoration: BoxDecoration(gradient: LinearGradient(
                            begin: Alignment.bottomCenter, end: Alignment.topCenter,
                            colors: [
                              (isDark ? AppTheme.darkBackground : AppTheme.surfaceLight).withValues(alpha: 1.0),
                              (isDark ? AppTheme.darkBackground : AppTheme.surfaceLight).withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                          )),
                        )),
                      ),
                      // Source badge
                      Positioned(
                        left: 16, bottom: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          color: AppTheme.primaryContainer,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.source_rounded, size: 12, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(widget.article.sourceName?.toUpperCase() ?? 'NEWS',
                                style: AppTheme.labelBold.copyWith(fontSize: 10, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(color: AppTheme.cardBgFor(isDark)),
          ),
        ),

        // Article content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE
                Text(
                  widget.article.title,
                  style: AppTheme.headlineLgMobile.copyWith(
                    color: AppTheme.textPrimaryFor(isDark),
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 16),

                // Meta: Author + Time
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
                          (widget.article.author != null && widget.article.author!.isNotEmpty)
                              ? widget.article.author![0].toUpperCase() : 'N',
                          style: AppTheme.labelBold.copyWith(
                            color: AppTheme.primaryContainer,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.article.author ?? 'Redaksi',
                            style: AppTheme.labelBold.copyWith(
                              fontSize: 13,
                              color: AppTheme.textPrimaryFor(isDark),
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 11,
                                  color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.7)),
                              const SizedBox(width: 4),
                              Text(
                                DateFormatter.getRelativeTime(widget.article.publishedAt).toUpperCase(),
                                style: AppTheme.labelSm.copyWith(
                                  fontSize: 10,
                                  color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.7)),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.source_rounded, size: 11,
                                  color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.7)),
                              const SizedBox(width: 4),
                              Text(
                                widget.article.sourceName ?? 'Sumber',
                                style: AppTheme.labelSm.copyWith(
                                  fontSize: 10,
                                  color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.7)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Accent divider
                Container(
                  height: 3, width: 48,
                  color: AppTheme.primaryContainer,
                ),
                const SizedBox(height: 20),

                // Editor analysis
                _buildEditorAnalysis(isDark),
                const SizedBox(height: 24),

                // Info panel
                _buildInfoPanel(isDark),
                const SizedBox(height: 20),

                // Hint
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.primaryContainer.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.open_in_new_rounded, size: 18,
                          color: AppTheme.primaryContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ketuk tombol "BACA LENGKAP" di bawah untuk membuka artikel asli di browser.',
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
    );
  }

  Widget _buildEditorAnalysis(bool isDark) {
    // Loading state
    if (_isAnalyzing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ANALISIS EDITOR',
              style: AppTheme.labelBold.copyWith(fontSize: 11, color: AppTheme.primaryContainer, letterSpacing: 1)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.dividerFor(isDark).withValues(alpha: 0.5),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryContainer),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Editor REEDFEEDS sedang menganalisis artikel...',
                    style: AppTheme.labelSm.copyWith(
                        fontSize: 11, color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.7))),
              ],
            ),
          ),
        ],
      );
    }

    // Error state
    if (_analysisError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('ANALISIS EDITOR',
                  style: AppTheme.labelBold.copyWith(fontSize: 11, color: AppTheme.primaryContainer, letterSpacing: 1)),
              const Spacer(),
              GestureDetector(
                onTap: _startAnalysis,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 12,
                        color: AppTheme.primaryContainer.withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Text('Coba lagi',
                        style: AppTheme.labelSm.copyWith(
                            fontSize: 10, color: AppTheme.primaryContainer.withValues(alpha: 0.7))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.dividerFor(isDark).withValues(alpha: 0.5), width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16,
                    color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.5)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Gagal menganalisis artikel. Silakan baca ringkasan di bawah ini.',
                      style: AppTheme.labelSm.copyWith(
                          fontSize: 11, color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.7))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (widget.article.description != null && widget.article.description!.isNotEmpty) ...[
            Text('RINGKASAN',
                style: AppTheme.labelBold.copyWith(fontSize: 11, color: AppTheme.primaryContainer, letterSpacing: 1)),
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
              child: Text(widget.article.description!,
                  style: AppTheme.bodyMd.copyWith(
                      fontSize: 14, color: AppTheme.textPrimaryFor(isDark))),
            ),
          ],
        ],
      );
    }

    if (_analysis == null) return const SizedBox.shrink();

    final analysis = _analysis!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              color: AppTheme.primaryContainer,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text('ANALISIS EDITOR REEDFEEDS',
                      style: AppTheme.labelBold.copyWith(fontSize: 9, color: Colors.white, letterSpacing: 0.8)),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _startAnalysis,
              child: Icon(Icons.refresh_rounded, size: 14,
                  color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.5)),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
              Text(analysis.judulSaran,
                  style: AppTheme.headlineMd.copyWith(
                      fontSize: 18, color: AppTheme.textPrimaryFor(isDark))),
              const SizedBox(height: 12),
              Container(height: 2, width: 32, color: AppTheme.primaryContainer),
              const SizedBox(height: 12),
              Text(analysis.intiBerita,
                  style: AppTheme.bodyMd.copyWith(
                      fontSize: 14, color: AppTheme.textPrimaryFor(isDark))),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (analysis.poinKunci.isNotEmpty) ...[
          Text('POIN PENTING',
              style: AppTheme.labelBold.copyWith(
                  fontSize: 11, color: AppTheme.textSecondaryFor(isDark), letterSpacing: 1)),
          const SizedBox(height: 10),
          ...analysis.poinKunci.asMap().entries.map((entry) {
            final i = entry.key + 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(child: Text('$i',
                        style: AppTheme.labelBold.copyWith(
                            fontSize: 10, color: AppTheme.primaryContainer))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(entry.value,
                        style: AppTheme.bodyMd.copyWith(
                            fontSize: 13, color: AppTheme.textSecondaryFor(isDark))),
                  ),
                ],
              ),
            );
          }),
        ],
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.dividerFor(isDark).withValues(alpha: 0.3), width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 12,
                  color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.4)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _analysisService.isAiMode
                      ? 'Analisis oleh AI Editor REEDFEEDS.'
                      : 'Analisis otomatis oleh Editor REEDFEEDS.',
                  style: AppTheme.labelSm.copyWith(
                    fontSize: 10,
                    color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPanel(bool isDark) {
    final article = widget.article;
    final url = Uri.tryParse(article.url);
    final domain = url?.host.replaceFirst('www.', '') ?? 'Sumber tidak diketahui';

    return Container(
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
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryContainer.withValues(alpha: 0.3), width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.info_outline_rounded, size: 14,
                    color: AppTheme.primaryContainer),
              ),
              const SizedBox(width: 8),
              Text('DETAIL ARTIKEL',
                  style: AppTheme.labelBold.copyWith(
                      fontSize: 11, color: AppTheme.textSecondaryFor(isDark), letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.person_outline_rounded, 'Penulis',
              article.author ?? 'Tidak tercantum', isDark),
          _infoRow(Icons.source_rounded, 'Sumber',
              article.sourceName ?? 'Tidak diketahui', isDark),
          _infoRow(Icons.language_rounded, 'Domain', domain, isDark),
          _infoRow(Icons.schedule_rounded, 'Publikasi',
              _formatFullDate(article.publishedAt), isDark),
          Divider(height: 24,
              color: AppTheme.dividerFor(isDark).withValues(alpha: 0.5)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.link_rounded, size: 14,
                  color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.5)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(article.url,
                    style: AppTheme.labelSm.copyWith(
                      fontSize: 10,
                      color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.6),
                    ),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: article.url));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('URL disalin ke clipboard'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppTheme.cardBgFor(isDark),
                      duration: const Duration(seconds: 2),
                    ));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.copy_rounded, size: 12,
                      color: AppTheme.primaryContainer.withValues(alpha: 0.6)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 14,
              color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(label,
                style: AppTheme.labelSm.copyWith(
                  fontSize: 10,
                  color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.6),
                )),
          ),
          Expanded(
            child: Text(value,
                style: AppTheme.labelBold.copyWith(
                  fontSize: 12,
                  color: AppTheme.textPrimaryFor(isDark),
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minute';
    } catch (_) { return dateStr; }
  }

  Widget _buildBottomBar(bool isDark) {
    if (_hasOpenedArticle) {
      return Container(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: AppTheme.cardBgFor(isDark).withValues(alpha: 0.95),
          border: Border(top: BorderSide(
            color: AppTheme.dividerFor(isDark).withValues(alpha: 0.5))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, size: 16,
                color: const Color(0xFF00C853).withValues(alpha: 0.7)),
            const SizedBox(width: 8),
            Text('Artikel dibuka di browser',
                style: AppTheme.labelSm.copyWith(
                    fontSize: 12, color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.7))),
          ],
        ),
      );
    }

    return Container(
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
        height: 48,
        child: ElevatedButton.icon(
          onPressed: _openInBrowser,
          icon: const Icon(Icons.open_in_new_rounded, size: 20, color: Colors.white),
          label: Text('BACA LENGKAP',
              style: AppTheme.labelBold.copyWith(color: Colors.white, fontSize: 14, letterSpacing: 0.8)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
