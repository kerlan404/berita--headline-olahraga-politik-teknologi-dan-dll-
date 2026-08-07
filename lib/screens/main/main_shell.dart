import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/bookmark_provider.dart';
import '../bookmark/bookmark_screen.dart';
import '../home/home_screen.dart';
import '../about/about_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<Widget> _screens = const [
    HomeScreen(),
    BookmarkScreen(),
    AboutScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.dividerFor(Theme.of(context).brightness == Brightness.dark), width: 2),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.cardBgFor(Theme.of(context).brightness == Brightness.dark),
        selectedItemColor: AppTheme.primaryContainer,
        unselectedItemColor: AppTheme.textSecondaryFor(Theme.of(context).brightness == Brightness.dark),
        selectedLabelStyle: AppTheme.labelBold.copyWith(fontSize: 11),
        unselectedLabelStyle: AppTheme.labelSm.copyWith(fontSize: 11),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: _buildNavItem(Icons.home_outlined, Icons.home_rounded, 0),
            activeIcon: _buildNavItem(Icons.home_rounded, Icons.home_rounded, 0),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: _buildBookmarkNav(false),
            activeIcon: _buildBookmarkNav(true),
            label: 'SAVED',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem(Icons.info_outline, Icons.info_rounded, 2),
            activeIcon: _buildNavItem(Icons.info_rounded, Icons.info_rounded, 2),
            label: 'ABOUT',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData outline, IconData filled, int index) {
    final isActive = _currentIndex == index;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isActive)
          Container(
            height: 3,
            width: 24,
            color: AppTheme.primaryContainer,
          ),
        const SizedBox(height: 6),
        Icon(isActive ? filled : outline),
      ],
    );
  }

  Widget _buildBookmarkNav(bool isActive) {
    return Consumer<BookmarkProvider>(
      builder: (context, provider, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Container(
                height: 3,
                width: 24,
                color: AppTheme.primaryContainer,
              ),
            const SizedBox(height: 6),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(isActive ? Icons.bookmark_rounded : Icons.bookmark_border),
                if (provider.count > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.cardBgFor(Theme.of(context).brightness == Brightness.dark),
                          width: 1.5,
                        ),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 12),
                      child: Text(
                        provider.count > 99 ? '99+' : provider.count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
