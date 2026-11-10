
import 'package:flutter/material.dart';

import 'app_theme.dart';
import '../screens/dashboard_screen.dart';
import '../screens/archive_builder_screen.dart';
import '../screens/benchmark_screen.dart';
import '../screens/inspector_screen.dart';
import '../screens/history_screen.dart';
import '../screens/about_screen.dart';

class ZippeddonApp extends StatelessWidget {
  const ZippeddonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZIPPEDDON',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      initialRoute: '/',
      routes: {
        '/': (_) => const DashboardScreen(),
        '/builder': (_) => const ArchiveBuilderScreen(),
        '/benchmark': (_) => const BenchmarkScreen(),
        '/inspector': (_) => const InspectorScreen(),
        '/history': (_) => const HistoryScreen(),
        '/about': (_) => const AboutScreen(),
      },
    );
  }
}
