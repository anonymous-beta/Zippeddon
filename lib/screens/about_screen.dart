
import 'package:flutter/material.dart';

import '../core/config.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About ZIPPEDDON')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 72,
            color: Color(0xFFFF6A24),
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'ZIPPEDDON',
              style: TextStyle(
                fontSize: 28,
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
            'ZIPPEDDON is a controlled archive research application '
            'for creating bounded ZIP test files, benchmarking '
            'compression, inspecting archive structures and '
            'evaluating extraction safety.',
          ),
          const SizedBox(height: 20),
          const Text(
            'SAFETY DESIGN',
            style: TextStyle(
              color: Color(0xFFFF6A24),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Archive generation and benchmarking are deliberately '
            'bounded. The inspector checks extraction size, file count, '
            'expansion ratio and unsafe paths before extraction.',
          ),
          const SizedBox(height: 28),
          const Divider(),
          const ListTile(
            title: Text('Developer'),
            subtitle: Text('Anonymous_beta'),
          ),
          ListTile(
            title: const Text('Application'),
            subtitle: Text(AppConfig.appName),
          ),
          const ListTile(
            title: Text('Platform'),
            subtitle: Text('Flutter · Android · iOS'),
          ),
        ],
      ),
    );
  }
}
