import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text('PROFILE',
                style: AppTheme.headlineMd.copyWith(
                    fontSize: 20, color: AppTheme.textPrimaryFor(isDark))),
          ],
        ),
      ),
      body: ListView(
        children: [
          // Hero section
          _buildHeroSection(context, isDark),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Team Identity
                _buildTeamIdentity(isDark),
                const SizedBox(height: 20),

                // Stats
                Consumer<BookmarkProvider>(
                  builder: (context, bookmark, child) {
                    return _buildStats(bookmarkCount: bookmark.count, isDark: isDark);
                  },
                ),
                const SizedBox(height: 20),

                // Info cards
                _buildInfoCard(
                  isDark: isDark,
                  icon: Icons.bolt_rounded,
                  title: 'BERITA CEPAT & TERPERCAYA',
                  subtitle: 'Headline terkini dari 7 kategori berbeda yang diperbarui secara real-time.',
                ),
                const SizedBox(height: 10),
                _buildInfoCard(
                  isDark: isDark,
                  icon: Icons.bookmark_rounded,
                  title: 'BOOKMARK OFFLINE',
                  subtitle: 'Simpan artikel favorit dan baca nanti — data tersimpan di perangkat Anda.',
                ),
                const SizedBox(height: 10),
                _buildInfoCard(
                  isDark: isDark,
                  icon: Icons.offline_bolt_rounded,
                  title: 'CACHE OFFLINE',
                  subtitle: 'Berita yang sudah dimuat akan di-cache, bisa dibaca tanpa internet.',
                ),

                const SizedBox(height: 24),

                // Theme toggle
                _buildThemeToggle(context, isDark),
                const SizedBox(height: 32),

                // Credits
                Column(
                  children: [
                    Icon(Icons.favorite_rounded, size: 16,
                        color: AppTheme.primaryContainer.withValues(alpha: 0.5)),
                    const SizedBox(height: 8),
                    Text('Data berita disediakan oleh NewsAPI.org',
                        style: AppTheme.labelSm.copyWith(
                            fontSize: 11, color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.6)),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text('REEDFEEDS v1.0.0',
                        style: AppTheme.labelSm.copyWith(
                            fontSize: 10, color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.4))),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.dividerFor(isDark).withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        children: [
          // App icon
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryContainer.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.explore_rounded, color: Colors.white, size: 36),
                SizedBox(height: 2),
                Text('RF', style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w900,
                    color: Colors.white, letterSpacing: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // App name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('REED',
                  style: AppTheme.headlineMd.copyWith(
                      fontSize: 28, color: AppTheme.textPrimaryFor(isDark), letterSpacing: 1.2)),
              Text('FEEDS',
                  style: AppTheme.headlineMd.copyWith(
                      fontSize: 28, color: AppTheme.primaryContainer, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            color: AppTheme.primaryContainer.withValues(alpha: 0.08),
            child: Text('BERITA & HEADLINE TERKINI',
                style: AppTheme.labelBold.copyWith(
                    fontSize: 10, color: AppTheme.primaryContainer, letterSpacing: 2)),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.primaryContainer.withValues(alpha: 0.3), width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('v1.0.0',
                style: AppTheme.labelBold.copyWith(
                    fontSize: 11, color: AppTheme.primaryContainer, letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamIdentity(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.primaryContainer.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            color: AppTheme.primaryContainer,
            child: Text('IDENTITAS KELOMPOK',
                style: AppTheme.labelBold.copyWith(
                    fontSize: 10, color: Colors.white, letterSpacing: 2)),
          ),
          const SizedBox(height: 16),

          // Kelompok & Kelas
          Row(
            children: [
              _buildTeamItem(Icons.group_rounded, 'Kelompok', 'Kelompok 2', isDark),
              Container(width: 1, height: 40,
                  color: AppTheme.dividerFor(isDark).withValues(alpha: 0.3)),
              _buildTeamItem(Icons.school_rounded, 'Kelas', 'XII RPL 2', isDark),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1,
              color: AppTheme.dividerFor(isDark).withValues(alpha: 0.3)),
          const SizedBox(height: 14),

          // Member 1
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryContainer.withValues(alpha: 0.3), width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text('1',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14,
                          color: AppTheme.primaryContainer)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mochammad Rezy Alfarabi',
                        style: AppTheme.labelBold.copyWith(
                            fontSize: 13, color: AppTheme.textPrimaryFor(isDark))),
                    const SizedBox(height: 2),
                    Text('Manajer Proyek & Developer',
                        style: AppTheme.labelSm.copyWith(
                          fontSize: 10,
                          color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.7),
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Member 2
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryContainer.withValues(alpha: 0.3), width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text('2',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14,
                          color: AppTheme.primaryContainer)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ahmad Fahmi',
                        style: AppTheme.labelBold.copyWith(
                            fontSize: 13, color: AppTheme.textPrimaryFor(isDark))),
                    const SizedBox(height: 2),
                    Text('Anggota Tim',
                        style: AppTheme.labelSm.copyWith(
                          fontSize: 10,
                          color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.7),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamItem(IconData icon, String label, String value, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryContainer),
          const SizedBox(height: 6),
          Text(label,
              style: AppTheme.labelSm.copyWith(
                fontSize: 10,
                color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.7),
              )),
          const SizedBox(height: 2),
          Text(value,
              style: AppTheme.labelBold.copyWith(
                fontSize: 13,
                color: AppTheme.textPrimaryFor(isDark),
              )),
        ],
      ),
    );
  }

  Widget _buildStats({required int bookmarkCount, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.dividerFor(isDark).withValues(alpha: 0.5), width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.bookmark_rounded,
            value: '$bookmarkCount',
            label: 'SAVED',
            isDark: isDark,
          ),
          Container(width: 1, height: 48,
              color: AppTheme.dividerFor(isDark).withValues(alpha: 0.5)),
          _buildStatItem(
            icon: Icons.category_rounded,
            value: '7',
            label: 'CATEGORIES',
            isDark: isDark,
          ),
          Container(width: 1, height: 48,
              color: AppTheme.dividerFor(isDark).withValues(alpha: 0.5)),
          _buildStatItem(
            icon: Icons.language_rounded,
            value: 'ID',
            label: 'LANGUAGE',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.dividerFor(isDark).withValues(alpha: 0.3), width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, size: 20,
                color: AppTheme.primaryContainer),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: AppTheme.headlineMd.copyWith(
                  fontSize: 20, color: AppTheme.textPrimaryFor(isDark))),
          const SizedBox(height: 2),
          Text(label,
              style: AppTheme.labelSm.copyWith(
                  fontSize: 10, color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.dividerFor(isDark).withValues(alpha: 0.5), width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTheme.labelBold.copyWith(
                        fontSize: 13, color: AppTheme.textPrimaryFor(isDark))),
                const SizedBox(height: 6),
                Text(subtitle,
                    style: AppTheme.labelSm.copyWith(
                      fontSize: 11,
                      color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.8),
                      height: 1.5,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, bool isDark) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.dividerFor(isDark).withValues(alpha: 0.5), width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  themeProvider.isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: Colors.white, size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      themeProvider.isDarkMode ? 'DARK MODE' : 'LIGHT MODE',
                      style: AppTheme.labelBold.copyWith(
                          fontSize: 13, color: AppTheme.textPrimaryFor(isDark)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      themeProvider.isDarkMode
                          ? 'Beralih ke tema terang'
                          : 'Beralih ke tema gelap',
                      style: AppTheme.labelSm.copyWith(
                        fontSize: 11,
                        color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => themeProvider.toggleTheme(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: 52, height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: themeProvider.isDarkMode
                        ? AppTheme.primaryContainer
                        : AppTheme.darkBackground,
                  ),
                  padding: const EdgeInsets.all(3),
                  alignment: themeProvider.isDarkMode
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      size: 12,
                      color: themeProvider.isDarkMode
                          ? AppTheme.primaryContainer
                          : AppTheme.darkBackground,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
