import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/news_article.dart';
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
  // WebView only works on mobile platforms, not web
  WebViewController? _controller;
  int _progress = 0;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initWebView();
    }
  }

  void _initWebView() {
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (mounted) {
                setState(() {
                  _progress = progress;
                });
              }
            },
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _progress = 0;
                  _isError = false;
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _progress = 100;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (error.errorType != WebResourceErrorType.unknown) {
                if (mounted) {
                  setState(() {
                    _isError = true;
                  });
                }
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.article.url));
    } catch (e) {
      // WebView initialization failed, fall back to error state
      if (mounted) {
        setState(() {
          _isError = true;
        });
      }
    }
  }

  Future<void> _launchInBrowser() async {
    final Uri url = Uri.parse(widget.article.url);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak bisa membuka tautan';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka browser: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _shareArticle() {
    final text = '${widget.article.title}\n\n${widget.article.url}';
    Share.share(text, subject: widget.article.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          BookmarkButton(
            article: widget.article,
            iconSize: 22,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Bagikan Berita',
            onPressed: _shareArticle,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Buka di Browser',
            onPressed: _launchInBrowser,
          ),
        ],
        bottom: !kIsWeb && _progress < 100 && !_isError
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2.0),
                child: LinearProgressIndicator(
                  value: _progress / 100.0,
                  backgroundColor: AppTheme.background,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryAccent),
                  minHeight: 2.0,
                ),
              )
            : null,
      ),
      body: kIsWeb ? _buildWebFallback() : _buildMobileView(),
    );
  }

  Widget _buildWebFallback() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Article Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.article.urlToImage ?? '',
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: AppTheme.surface,
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 48, color: AppTheme.textSecondary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Source & Time
          Row(
            children: [
              Icon(Icons.source, size: 14, color: AppTheme.primaryAccent),
              const SizedBox(width: 6),
              Text(
                widget.article.sourceName?.toUpperCase() ?? 'NEWS',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryAccent,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.schedule, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(
                DateFormatter.getRelativeTime(widget.article.publishedAt),
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            widget.article.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Author
          if (widget.article.author != null && widget.article.author!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    widget.article.author!,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),

          // Divider
          Container(height: 1, color: AppTheme.divider),
          const SizedBox(height: 16),

          // Description
          if (widget.article.description != null && widget.article.description!.isNotEmpty)
            Text(
              widget.article.description!,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
                height: 1.6,
              ),
            ),
          const SizedBox(height: 8),

          // Content
          if (widget.article.content != null && widget.article.content!.isNotEmpty)
            Text(
              widget.article.content!,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
            ),
          const SizedBox(height: 32),

          // Open in Browser Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _launchInBrowser,
              icon: const Icon(Icons.open_in_browser, color: Colors.white),
              label: const Text(
                'BUKA ARTIKEL LENGKAP',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMobileView() {
    return Stack(
      children: [
        if (!_isError && _controller != null)
          WebViewWidget(controller: _controller!),
        if (_isError || _controller == null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.signal_wifi_off_rounded,
                    size: 64,
                    color: AppTheme.primaryAccent,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Halaman Gagal Dimuat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ada masalah saat memuat halaman web ini. Silakan coba lagi atau buka langsung di browser bawaan HP.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isError = false;
                          });
                          _initWebView();
                        },
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text('Muat Ulang', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.surface,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _launchInBrowser,
                        icon: const Icon(Icons.open_in_browser, color: Colors.white),
                        label: const Text('Buka di Browser', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
