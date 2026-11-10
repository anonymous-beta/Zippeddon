
import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../core/config.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About ZIPPEDDON'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 78,
            color: AppTheme.magma,
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'ZIPPEDDON',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text('Archive Research & Compression Lab'),
          ),
          const SizedBox(height: 28),
          const Text(
            'ZIPPEDDON is a ZIP archive research application '
            'for creating bounded test archives, measuring '
            'compression performance, inspecting archive '
            'structures and checking extraction safety.',
          ),
          const SizedBox(height: 24),
          const Text(
            'SAFETY DESIGN',
            style: TextStyle(
              color: AppTheme.magma,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Archive generation and benchmarks use fixed resource '
            'limits. Archive inspection checks entry counts, '
            'expanded sizes, expansion ratios and unsafe paths. '
            'The application is designed for controlled testing.',
          ),
          const SizedBox(height: 24),
          const Divider(),
          const ListTile(
            title: Text('Developer'),
            subtitle: Text('Anonymous_beta'),
          ),
          const ListTile(
            title: Text('Application'),
            subtitle: Text(ZippeddonConfig.appName),
          ),
          const ListTile(
            title: Text('Version'),
            subtitle: Text(ZippeddonConfig.version),
          ),
          const ListTile(
            title: Text('Platform'),
            subtitle: Text('Flutter · Android · iOS'),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'BUILT BY ANONYMOUS_BETA',
              style: TextStyle(
                color: AppTheme.toxic,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
