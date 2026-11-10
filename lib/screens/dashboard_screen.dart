
import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../core/config.dart';
import 'archive_builder_screen.dart';
import 'benchmark_screen.dart';
import 'history_screen.dart';
import 'inspector_screen.dart';
import 'about_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZIPPEDDON'),
        actions: [
          IconButton(
            tooltip: 'About',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AboutScreen(),
              ),
            ),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF252A24),
                    Color(0xFF111511),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: AppTheme.accent.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ARCHIVE LAB',
                    style: TextStyle(
                      color: AppTheme.accent,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Explore compression.\nMeasure the limits.',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A controlled ZIP archive research toolkit.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ANONYMOUS_BETA',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: AppTheme.accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _FeatureTile(
              icon: Icons.folder_zip_outlined,
              title: 'Archive Builder',
              subtitle: 'Create bounded ZIP test archives',
              onTap: () => _open(
                context,
                const ArchiveBuilderScreen(),
              ),
            ),
            _FeatureTile(
              icon: Icons.speed,
              title: 'Compression Benchmark',
              subtitle: 'Measure compression and integrity',
              onTap: () => _open(
                context,
                const BenchmarkScreen(),
              ),
            ),
            _FeatureTile(
              icon: Icons.manage_search,
              title: 'Archive Inspector',
              subtitle: 'Inspect entries and extraction limits',
              onTap: () => _open(
                context,
                const InspectorScreen(),
              ),
            ),
            _FeatureTile(
              icon: Icons.history,
              title: 'Archive History',
              subtitle: 'Review previous operations',
              onTap: () => _open(
                context,
                const HistoryScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: Icon(
          icon,
          color: AppTheme.accent,
          size: 28,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
