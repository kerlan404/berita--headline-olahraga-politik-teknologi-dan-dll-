import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/route_transitions.dart';
import '../../providers/search_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry_widget.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/news_card.dart';
import '../detail/detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Clear search states on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().clearSearch();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<SearchProvider>().loadMore();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<SearchProvider>().search(query, isRefresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Cari topik atau judul berita...',
              hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              border: InputBorder.none,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: () {
                        _searchController.clear();
                        context.read<SearchProvider>().clearSearch();
                      },
                    )
                  : null,
            ),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textInputAction: TextInputAction.search,
            onChanged: _onSearchChanged,
          ),
        ),
      ),
      body: Consumer<SearchProvider>(
        builder: (context, provider, child) {
          if (provider.query.trim().isEmpty) {
            return const EmptyState(
              title: 'Cari Berita',
              description: 'Ketik kata kunci judul atau deskripsi berita di atas.',
              icon: Icons.search,
            );
          }

          if (provider.isLoading && provider.searchResults.isEmpty) {
            return const LoadingIndicator();
          }

          if (provider.errorMessage != null && provider.searchResults.isEmpty) {
            return ErrorRetryWidget(
              errorMessage: provider.errorMessage!,
              onRetry: () => provider.search(provider.query, isRefresh: true),
            );
          }

          if (provider.searchResults.isEmpty) {
            return EmptyState(
              title: 'Tidak Ada Hasil',
              description: 'Tidak ada berita yang cocok untuk "${provider.query}".',
              icon: Icons.search_off,
            );
          }

          return ListView.builder(
            controller: _scrollController,
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
}
