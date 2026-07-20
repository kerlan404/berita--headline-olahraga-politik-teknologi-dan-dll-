import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/bookmark_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PROFIL',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
      ),
      body: ListView(
        children: [
          // ── Hero Section ──
          _buildHeroSection(context),
          const SizedBox(height: 20),

          // ── Content ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Stats Row
                _buildStatsRow(context),
                const SizedBox(height: 20),

                // Info Cards
                _buildInfoCard(
                  icon: Icons.info_outline_rounded,
                  iconBgColor: const Color(0xFF4FC3F7).withValues(alpha: 0.15),
                  iconColor: const Color(0xFF4FC3F7),
                  title: 'Tentang Aplikasi',
                  subtitle: 'Aplikasi berita dan headline terkini yang menyajikan informasi dari berbagai kategori terpercaya.',
                ),
                const SizedBox(height: 10),
                _buildInfoCard(
                  icon: Icons.category_rounded,
                  iconBgColor: const Color(0xFF81C784).withValues(alpha: 0.15),
                  iconColor: const Color(0xFF81C784),
                  title: 'Kategori Berita',
                  subtitle: 'Olahraga, Teknologi, Bisnis, Hiburan, Kesehatan, dan masih banyak lagi.',
                ),
                const SizedBox(height: 10),
                _buildInfoCard(
                  icon: Icons.bookmark_rounded,
                  iconBgColor: const Color(0xFFFFB74D).withValues(alpha: 0.15),
                  iconColor: const Color(0xFFFFB74D),
                  title: 'Bookmark',
                  subtitle: 'Simpan artikel favorit Anda dengan menekan ikon bookmark pada setiap berita.',
                ),

                const SizedBox(height: 32),

                // Credits
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Icon(Icons.favorite_rounded, size: 14, color: AppTheme.primaryAccent.withValues(alpha: 0.5)),
                      const SizedBox(height: 8),
                      const Text(
                        'Data berita disediakan oleh NewsAPI.org',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ReedsFeed v1.0.0',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary.withValues(alpha: 0.6),
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

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryAccent.withValues(alpha: 0.15),
            AppTheme.primaryAccent.withValues(alpha: 0.05),
            AppTheme.background,
          ],
        ),
        border: Border(
          bottom: BorderSide(color: AppTheme.divider),
        ),
      ),
      child: Column(
        children: [
          // App Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryAccent,
                  AppTheme.primaryAccent.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryAccent.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.sports_kabaddi_outlined,
              color: Colors.white,
              size: 42,
            ),
          ),
          const SizedBox(height: 16),

          // App Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'REEDS',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Text(
                'FEED',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AppTheme.primaryAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'BERITA & HEADLINE TERKINI',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2.5,
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
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

  Widget _buildStatsRow(BuildContext context) {
    return Consumer<BookmarkProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Row(
            children: [
              _buildStatItem(
                icon: Icons.bookmark_rounded,
                value: '${provider.count}',
                label: 'Tersimpan',
                iconColor: AppTheme.primaryAccent,
              ),
              _buildDivider(),
              _buildStatItem(
                icon: Icons.category_rounded,
                value: '${6}',
                label: 'Kategori',
                iconColor: const Color(0xFF81C784),
              ),
              _buildDivider(),
              _buildStatItem(
                icon: Icons.language_rounded,
                value: 'ID',
                label: 'Bahasa',
                iconColor: const Color(0xFF4FC3F7),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      color: AppTheme.divider,
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
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
}
