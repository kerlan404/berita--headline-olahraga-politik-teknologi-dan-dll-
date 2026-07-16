import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/route_transitions.dart';
import '../../providers/news_list_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry_widget.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/news_card.dart';
import '../../widgets/news_hero_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../detail/detail_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _staggeredController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _staggeredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsListProvider>().fetchNews(isRefresh: true);
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _staggeredController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<NewsListProvider>().loadMore();
    }
  }

  void _triggerStaggeredAnimation() {
    _staggeredController.reset();
    _staggeredController.forward();
  }

  String _getCurrentLabel(String category) {
    for (final entry in ApiConstants.categoryMap.entries) {
      if (entry.value == category) return entry.key;
    }
    return ApiConstants.allCategory;
  }

  IconData _getCategoryIcon(String label) {
    switch (label) {
      case 'Semua': return Icons.explore;
      case 'Olahraga': return Icons.sports_soccer;
      case 'Teknologi': return Icons.computer;
      case 'Bisnis': return Icons.business_center;
      case 'Hiburan': return Icons.movie;
      case 'Kesehatan': return Icons.favorite;
      default: return Icons.article;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ApiConstants.categories;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Kategori',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Consumer<NewsListProvider>(
          builder: (context, provider, child) {
            final currentLabel = _getCurrentLabel(provider.currentCategory);
            return GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: Row(
                children: [
                  const Text(
                    'SPORTS',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  Text(
                    'FEED',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryAccent,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(currentLabel),
                          size: 12,
                          color: AppTheme.primaryAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currentLabel.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryAccent,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_drop_down, size: 14, color: AppTheme.primaryAccent),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Cari Berita',
            onPressed: () {
              Navigator.of(context).push(
                SlideRightRoute(page: const SearchScreen()),
              );
            },
          ),
        ],
      ),
      // Sidebar Drawer untuk kategori
      drawer: Drawer(
        backgroundColor: AppTheme.surface,
        child: Consumer<NewsListProvider>(
          builder: (context, provider, child) {
            final currentLabel = _getCurrentLabel(provider.currentCategory);
            return Column(
              children: [
                // Header Drawer
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.sports_kabaddi_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'SPORTSFEED',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const Text(
                          'Pilih kategori berita',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Daftar Kategori
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final label = categories[index];
                      final isSelected = label == currentLabel;
                      return _buildDrawerItem(
                        icon: _getCategoryIcon(label),
                        label: label,
                        isSelected: isSelected,
                        onTap: () {
                          final apiKeyName = ApiConstants.categoryMap[label] ?? 'all';
                          provider.setCategory(apiKeyName);
                          Navigator.pop(context); // close drawer
                          _triggerStaggeredAnimation();
                        },
                      );
                    },
                  ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppTheme.divider),
                    ),
                  ),
                  child: const Text(
                    'Berita & Headline Terkini',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: Consumer<NewsListProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.articles.isEmpty) {
            return const ShimmerList(itemCount: 5);
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
              title: 'Tidak ada berita',
              description: 'Saat ini belum ada berita untuk kategori ini.',
            );
          }

          if (!provider.isLoading && _staggeredController.value == 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _triggerStaggeredAnimation();
            });
          }

          return RefreshIndicator(
            color: AppTheme.primaryAccent,
            backgroundColor: AppTheme.surface,
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
                    child: NewsHeroCard(
                      article: article,
                      onTap: () => _openArticleDetail(context, article),
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

                return StaggeredListAnimation(
                  index: index,
                  controller: _staggeredController,
                  child: cardWidget,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryAccent.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppTheme.primaryAccent.withValues(alpha: 0.3))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? AppTheme.primaryAccent : AppTheme.textSecondary,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openArticleDetail(BuildContext context, dynamic article) {
    Navigator.of(context).push(
      SlideRightRoute(page: DetailScreen(article: article)),
    );
  }
}
