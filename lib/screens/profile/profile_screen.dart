import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/news_list_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryAccent, AppTheme.secondaryAccent],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'PROFIL',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          // ── Premium Hero Section ──
          _buildPremiumHero(context),
          const SizedBox(height: 20),

          // ── Content ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Stats Row
                Consumer<BookmarkProvider>(
                  builder: (context, bookmark, child) {
                    return _buildPremiumStats(
                      bookmarkCount: bookmark.count,
                      categories: 7,
                    );
                  },
                ),
                const SizedBox(height: 20),

                // ── Info Cards ──
                _buildPremiumInfoCard(
                  icon: Icons.bolt_rounded,
                  gradientColors: const [Color(0xFFD50000), Color(0xFFFF6D00)],
                  title: 'Berita Cepat & Terpercaya',
                  subtitle: 'Headline terkini dari 7 kategori berbeda yang diperbarui secara real-time langsung dari NewsAPI.',
                ),
                const SizedBox(height: 10),
                _buildPremiumInfoCard(
                  icon: Icons.dark_mode_rounded,
                  gradientColors: const [Color(0xFF4FC3F7), Color(0xFF0288D1)],
                  title: 'Tema Gelap Premium',
                  subtitle: 'Desain dark theme khas ESPN dengan aksen merah yang elegan, nyaman dibaca kapan saja.',
                ),
                const SizedBox(height: 10),
                _buildPremiumInfoCard(
                  icon: Icons.bookmark_rounded,
                  gradientColors: const [Color(0xFFFFB74D), Color(0xFFF57C00)],
                  title: 'Bookmark Offline',
                  subtitle: 'Simpan artikel favorit dan baca nanti — data tersimpan aman di perangkat Anda.',
                ),
                const SizedBox(height: 10),
                _buildPremiumInfoCard(
                  icon: Icons.offline_bolt_rounded,
                  gradientColors: const [Color(0xFF81C784), Color(0xFF388E3C)],
                  title: 'Cache Offline',
                  subtitle: 'Berita yang sudah dimuat akan di-cache selama 30 menit, bisa dibaca tanpa internet.',
                ),

                const SizedBox(height: 32),

                // ── TechStack Badges ──
                const Text(
                  'TECH STACK',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildTechBadge('Flutter', Icons.flutter_dash, const Color(0xFF4FC3F7)),
                    _buildTechBadge('Dart', Icons.code_rounded, const Color(0xFF81C784)),
                    _buildTechBadge('Provider', Icons.alt_route_rounded, const Color(0xFFCE93D8)),
                    _buildTechBadge('SQFlite', Icons.storage_rounded, const Color(0xFFFFB74D)),
                    _buildTechBadge('NewsAPI', Icons.api_rounded, AppTheme.primaryAccent),
                    _buildTechBadge('WebView', Icons.web_rounded, const Color(0xFF90CAF9)),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Credits ──
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        size: 16,
                        color: AppTheme.primaryAccent.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Data berita disediakan oleh NewsAPI.org',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ReedsFeed v1.0.0',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryAccent.withValues(alpha: 0.12),
            AppTheme.primaryAccent.withValues(alpha: 0.03),
            AppTheme.background,
          ],
        ),
        border: Border(
          bottom: BorderSide(color: AppTheme.divider.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        children: [
          // ── App Icon with glow ──
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryAccent,
                  AppTheme.secondaryAccent,
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryAccent.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppTheme.secondaryAccent.withValues(alpha: 0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.explore_rounded, color: Colors.white, size: 36),
                SizedBox(height: 2),
                Text(
                  'RF',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── App Name ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'REEDS',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Text(
                'FEED',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AppTheme.primaryAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'BERITA & HEADLINE TERKINI',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2.0,
                color: AppTheme.primaryAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Version pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryAccent.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'v1.0.0',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryAccent,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStats({
    required int bookmarkCount,
    required int categories,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          _buildPremiumStatItem(
            icon: Icons.bookmark_rounded,
            value: '$bookmarkCount',
            label: 'Tersimpan',
            color: AppTheme.primaryAccent,
          ),
          _buildStatDivider(),
          _buildPremiumStatItem(
            icon: Icons.category_rounded,
            value: '$categories',
            label: 'Kategori',
            color: const Color(0xFF81C784),
          ),
          _buildStatDivider(),
          _buildPremiumStatItem(
            icon: Icons.language_rounded,
            value: 'ID',
            label: 'Bahasa',
            color: const Color(0xFF4FC3F7),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 48,
      color: AppTheme.divider,
    );
  }

  Widget _buildPremiumInfoCard({
    required IconData icon,
    required List<Color> gradientColors,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechBadge(String name, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
