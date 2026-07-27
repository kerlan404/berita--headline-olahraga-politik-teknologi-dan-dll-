import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/news_list_provider.dart';
import 'providers/recent_activity_provider.dart';
import 'providers/search_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash/splash_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ThemeProvider>().loadTheme();
      context.read<BookmarkProvider>().loadFromDatabase();
      final activity = context.read<RecentActivityProvider>();
      context.read<NewsListProvider>().bindRecentActivity(activity);
      context.read<SearchProvider>().bindRecentActivity(activity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'REEDFEEDS',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.theme,
          home: const SplashScreen(),
        );
      },
    );
  }
}
