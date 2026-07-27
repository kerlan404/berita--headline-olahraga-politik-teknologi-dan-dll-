import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/route_transitions.dart';
import '../../data/models/news_article.dart';
import '../../providers/news_list_provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/breaking_news_banner.dart';
import '../../widgets/category_bar.dart';
import '../../widgets/compact_grid_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry_widget.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/news_card.dart';
import '../../widgets/news_hero_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../detail/detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _searchScrollController = ScrollController();
  late AnimationController _staggeredController;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  bool _isSearching = false;

  double _scrollOffset = 0.0;
  bool _isGridView = false;
  DateTime _lastParallaxUpdate = DateTime.now();

  bool _showFab = false;
  bool _showBreakingNews = true;

  @override
  void initState() {
    super.initState();
    _staggeredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NewsListProvider>();
      if (provider.articles.isEmpty || provider.needsRefresh) {
        provider.fetchNews(isRefresh: true);
      }
    });

    _scrollController.addListener(_onScroll);
    _searchScrollController.addListener(_onSearchScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchScrollController.dispose();
    _staggeredController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    final now = DateTime.now();
    if (now.difference(_lastParallaxUpdate).inMilliseconds > 50) {
      _scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
      _lastParallaxUpdate = now;
    }
    final showFab = _scrollController.hasClients && _scrollController.offset > 400;
    if (showFab != _showFab && mounted) {
      setState(() => _showFab = showFab);
    }
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<NewsListProvider>().loadMore();
    }
  }

  void _onSearchScroll() {
    if (_searchScrollController.position.pixels >=
        _searchScrollController.position.maxScrollExtent - 200) {
      context.read<SearchProvider>().loadMore();
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  void _triggerStaggeredAnimation() {
    _staggeredController.reset();
    _staggeredController.forward();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchFocusNode.unfocus();
        context.read<SearchProvider>().clearSearch();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus();
        });
      }
    });
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    final query = _searchController.text;
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<SearchProvider>().search(query, isRefresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSearching ? _buildSearchAppBar() : _buildNormalAppBar(),
      floatingActionButton: _showFab && !_isSearching
          ? FloatingActionButton.small(
              onPressed: _scrollToTop,
              backgroundColor: AppTheme.cardBgFor(Theme.of(context).brightness == Brightness.dark),
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryContainer.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: AppTheme.primaryContainer,
                ),
              ),
            )
          : null,
      body: Column(
        children: [
          if (!_isSearching)
            CategoryBar(onCategoryChanged: _triggerStaggeredAnimation),
          if (!_isSearching && _showBreakingNews)
            Consumer<NewsListProvider>(
              builder: (context, provider, child) {
                if (provider.articles.isEmpty) return const SizedBox.shrink();
                final breakingNews = provider.articles.length > 3
                    ? provider.articles.sublist(0, 3)
                    : provider.articles;
                return BreakingNewsBanner(
                  articles: breakingNews,
                  onArticleTap: (index) => _openArticleDetail(context, breakingNews[index]),
                  onDismiss: () => setState(() => _showBreakingNews = false),
                );
              },
            ),
          Expanded(
            child: _isSearching ? _buildSearchBody() : _buildNewsBody(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildNormalAppBar() {
    return AppBar(
      title: Row(
        children: [
          Text(
            'REED',
            style: AppTheme.headlineMd.copyWith(
              color: AppTheme.textPrimaryFor(Theme.of(context).brightness == Brightness.dark),
              fontSize: 22,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'FEEDS',
            style: AppTheme.headlineMd.copyWith(
              color: AppTheme.primaryContainer,
              fontSize: 22,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Cari Berita',
          onPressed: _toggleSearch,
        ),
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isGridView ? Icons.grid_view_rounded : Icons.view_list_rounded,
              key: ValueKey(_isGridView),
            ),
          ),
          tooltip: _isGridView ? 'Tampilan List' : 'Tampilan Grid',
          onPressed: () => setState(() => _isGridView = !_isGridView),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Tutup Pencarian',
        onPressed: _toggleSearch,
      ),
      title: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Cari topik atau judul berita...',
          hintStyle: AppTheme.bodyMd.copyWith(
            color: AppTheme.textSecondaryFor(Theme.of(context).brightness == Brightness.dark),
          ),
          border: InputBorder.none,
          filled: false,
        ),
        style: AppTheme.bodyMd.copyWith(
          color: AppTheme.textPrimaryFor(Theme.of(context).brightness == Brightness.dark),
        ),
        textInputAction: TextInputAction.search,
      ),
      actions: [
        ListenableBuilder(
          listenable: _searchController,
          builder: (context, _) {
            if (_searchController.text.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Hapus',
                onPressed: () {
                  _searchController.clear();
                  context.read<SearchProvider>().clearSearch();
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildNewsBody() {
    return Consumer<NewsListProvider>(
      builder: (context, provider, child) => _buildNewsContent(provider),
    );
  }

  Widget _buildNewsContent(NewsListProvider provider) {
    if (provider.isLoading && provider.articles.isEmpty) {
      return _isGridView
          ? const ShimmerGrid(itemCount: 6)
          : const ShimmerList(itemCount: 5);
    }

    if (provider.errorMessage != null && provider.articles.isEmpty) {
      return ErrorRetryWidget(
        errorMessage: provider.errorMessage!,
        onRetry: () {
          provider.fetchNews(isRefresh: true);
          _triggerStaggeredAnimation();
        },
      );
    }

    if (provider.articles.isEmpty) {
      return const EmptyState(
        title: 'TIDAK ADA BERITA',
        description: 'Saat ini belum ada berita untuk kategori ini.',
      );
    }

    if (!provider.isLoading && _staggeredController.value == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerStaggeredAnimation();
      });
    }

    if (_isGridView) return _buildGridContent(provider);
    return _buildListContent(provider);
  }

  Widget _buildListContent(NewsListProvider provider) {
    return RefreshIndicator(
      color: AppTheme.primaryContainer,
      backgroundColor: AppTheme.cardBgFor(Theme.of(context).brightness == Brightness.dark),
      onRefresh: () async {
        await provider.fetchNews(isRefresh: true);
        _triggerStaggeredAnimation();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: provider.articles.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.articles.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LoadingIndicator(isSmall: true),
            );
          }

          final article = provider.articles[index];

          Widget cardWidget;
          if (index == 0) {
            cardWidget = Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ListenableBuilder(
                listenable: _scrollController,
                builder: (context, _) => NewsHeroCard(
                  article: article,
                  onTap: () => _openArticleDetail(context, article),
                  scrollOffset: _scrollOffset,
                ),
              ),
            );
          } else {
            cardWidget = Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: NewsCard(
                article: article,
                onTap: () => _openArticleDetail(context, article),
              ),
            );
          }

          return RepaintBoundary(
            child: StaggeredListAnimation(
              index: index,
              controller: _staggeredController,
              child: cardWidget,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridContent(NewsListProvider provider) {
    return RefreshIndicator(
      color: AppTheme.primaryContainer,
      backgroundColor: AppTheme.cardBgFor(Theme.of(context).brightness == Brightness.dark),
      onRefresh: () async {
        await provider.fetchNews(isRefresh: true);
      },
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.72,
        ),
        itemCount: provider.articles.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.articles.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: LoadingIndicator(isSmall: true),
              ),
            );
          }

          final article = provider.articles[index];
          return CompactGridCard(
            article: article,
            onTap: () => _openArticleDetail(context, article),
          );
        },
      ),
    );
  }

  Widget _buildSearchBody() {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        if (provider.query.trim().isEmpty) {
          return _buildSearchHistory(provider);
        }

        if (provider.isLoading && provider.searchResults.isEmpty) {
          return const ShimmerList(itemCount: 4);
        }

        if (provider.errorMessage != null && provider.searchResults.isEmpty) {
          return ErrorRetryWidget(
            errorMessage: provider.errorMessage!,
            onRetry: () => provider.search(provider.query, isRefresh: true),
          );
        }

        if (provider.searchResults.isEmpty) {
          return EmptyState(
            title: 'TIDAK ADA HASIL',
            description: 'Tidak ada berita yang cocok untuk "${provider.query}".',
            icon: Icons.search_off,
          );
        }

        return ListView.builder(
          controller: _searchScrollController,
          padding: const EdgeInsets.all(12),
          itemCount: provider.searchResults.length + (provider.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == provider.searchResults.length) {
              return const LoadingIndicator(isSmall: true);
            }
            final article = provider.searchResults[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: NewsCard(
                article: article,
                onTap: () => _openArticleDetail(context, article),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchHistory(SearchProvider provider) {
    final history = provider.searchHistory;
    if (history.isEmpty) {
      return EmptyState(
        title: 'CARI BERITA',
        description: 'Ketik kata kunci judul atau deskripsi berita di atas.',
        icon: Icons.search,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(Icons.history_rounded, size: 16,
                  color: AppTheme.textSecondaryFor(Theme.of(context).brightness == Brightness.dark)),
              const SizedBox(width: 6),
              Text(
                'RIWAYAT PENCARIAN',
                style: AppTheme.labelBold.copyWith(
                  fontSize: 11,
                  color: AppTheme.textSecondaryFor(Theme.of(context).brightness == Brightness.dark),
                ),
              ),
            ],
          ),
        ),
        ...history.reversed.map((q) => ListTile(
          dense: true,
          leading: Icon(Icons.history_rounded, size: 18,
              color: AppTheme.textSecondaryFor(Theme.of(context).brightness == Brightness.dark)),
          title: Text(q,
              style: AppTheme.bodyMd.copyWith(fontSize: 14,
                  color: AppTheme.textPrimaryFor(Theme.of(context).brightness == Brightness.dark))),
          trailing: IconButton(
            icon: Icon(Icons.arrow_forward_rounded, size: 16,
                color: AppTheme.textSecondaryFor(Theme.of(context).brightness == Brightness.dark)),
            onPressed: () {
              _searchController.text = q;
              _searchController.selection = TextSelection.fromPosition(
                TextPosition(offset: q.length),
              );
              context.read<SearchProvider>().search(q, isRefresh: true);
            },
          ),
          contentPadding: EdgeInsets.zero,
        )),
        if (history.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: () => context.read<SearchProvider>().clearHistory(),
              child: Text('Hapus Riwayat',
                  style: AppTheme.labelSm.copyWith(
                      color: AppTheme.textSecondaryFor(Theme.of(context).brightness == Brightness.dark),
                      fontSize: 12)),
            ),
          ),
      ],
    );
  }

  void _openArticleDetail(BuildContext context, NewsArticle article) {
    context.read<NewsListProvider>().recordRead(article);
    Navigator.of(context).push(
      SlideRightRoute(page: DetailScreen(article: article)),
    );
  }
}

/// Staggered animation helper for list items
class StaggeredListAnimation extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;

  const StaggeredListAnimation({
    super.key,
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final delay = index * 0.05;
        final value = (controller.value - delay).clamp(0.0, 1.0);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
