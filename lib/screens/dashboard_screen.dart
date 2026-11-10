
import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../core/formatters.dart';
import '../services/history_service.dart';
import '../services/storage_service.dart';
import '../models/history_entry.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StorageService _storage = StorageService();
  final HistoryService _history = HistoryService();

  int _archiveCount = 0;
  int _storageUsed = 0;
  List<HistoryEntry> _recentEntries = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final results = await Future.wait([
        _storage.listArchives(),
        _storage.totalArchiveBytes(),
        _history.getEntries(),
      ]);

      final archives = results[0] as List;
      final storageBytes = results[1] as int;
      final historyEntries = results[2] as List<HistoryEntry>;

      if (!mounted) return;

      setState(() {
        _archiveCount = archives.length;
        _storageUsed = storageBytes;
        _recentEntries = historyEntries.take(4).toList();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Unable to load dashboard information.';
      });
    }
  }

  void _navigate(String route) {
    Navigator.pushNamed(context, route).then((_) {
      if (mounted) {
        _loadDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(
              Icons.folder_zip_rounded,
              color: AppTheme.magma,
              size: 25,
            ),
            SizedBox(width: 10),
            Text(
              'ZIPPEDDON',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh dashboard',
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        color: AppTheme.magma,
        backgroundColor: AppTheme.surface,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            _buildHero(),
            const SizedBox(height: 24),
            _buildSectionHeader(
              'SYSTEM OVERVIEW',
              'Your archive workspace',
            ),
            const SizedBox(height: 14),
            _buildStatistics(),
            const SizedBox(height: 28),
            _buildSectionHeader(
              'OPERATIONS',
              'Choose a tool',
            ),
            const SizedBox(height: 14),
            _buildFeatureGrid(),
            const SizedBox(height: 28),
            _buildSectionHeader(
              'RECENT ACTIVITY',
              'Latest archive operations',
              trailing: TextButton(
                onPressed: () => _navigate('/history'),
                child: const Text(
                  'VIEW ALL',
                  style: TextStyle(
                    color: AppTheme.magma,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildRecentActivity(),
            const SizedBox(height: 28),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.magma.withValues(alpha: 0.35),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF25201D),
            Color(0xFF151C22),
            Color(0xFF0B0F12),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.toxic.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 7,
                      color: AppTheme.toxic,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'ARCHIVE LAB ONLINE',
                      style: TextStyle(
                        color: AppTheme.toxic,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.bolt_rounded,
                color: AppTheme.magma,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'UNLEASH YOUR\nARCHIVE WORKFLOW.',
            style: TextStyle(
              fontSize: 27,
              height: 1.15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Build controlled ZIP archives, benchmark compression '
            'performance and inspect archive structures.',
            style: TextStyle(
              color: AppTheme.muted,
              height: 1.5,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _navigate('/builder'),
              icon: const Icon(Icons.folder_zip_rounded),
              label: const Text('OPEN ARCHIVE BUILDER'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String subtitle, {
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildStatistics() {
    if (_loading) {
      return const SizedBox(
        height: 115,
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.magma,
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.folder_zip_outlined,
            title: 'ARCHIVES',
            value: '$_archiveCount',
            accent: AppTheme.magma,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.storage_rounded,
            title: 'STORAGE USED',
            value: Formatters.bytes(_storageUsed),
            accent: AppTheme.toxic,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppTheme.surfaceLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: accent,
            size: 22,
          ),
          const SizedBox(height: 15),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _featureCard(
                icon: Icons.folder_zip_rounded,
                title: 'ARCHIVE BUILDER',
                description: 'Create controlled ZIP archives',
                accent: AppTheme.magma,
                onTap: () => _navigate('/builder'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _featureCard(
                icon: Icons.speed_rounded,
                title: 'BENCHMARK LAB',
                description: 'Measure compression performance',
                accent: AppTheme.toxic,
                onTap: () => _navigate('/benchmark'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _featureCard(
                icon: Icons.manage_search_rounded,
                title: 'ZIP INSPECTOR',
                description: 'Inspect files and archive structure',
                accent: AppTheme.toxic,
                onTap: () => _navigate('/inspector'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _featureCard(
                icon: Icons.history_rounded,
                title: 'OPERATION LOG',
                description: 'Review previous operations',
                accent: AppTheme.magma,
                onTap: () => _navigate('/history'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          constraints: const BoxConstraints(minHeight: 145),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: AppTheme.surfaceLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 21,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(
            color: AppTheme.magma,
          ),
        ),
      );
    }

    if (_error != null) {
      return _emptyActivity(
        Icons.warning_amber_rounded,
        _error!,
      );
    }

    if (_recentEntries.isEmpty) {
      return _emptyActivity(
        Icons.inventory_2_outlined,
        'No operations yet. Your recent archive activity will appear here.',
      );
    }

    return Column(
      children: _recentEntries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 9),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.surfaceLight,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            leading: Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                color: AppTheme.magma.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.folder_zip_outlined,
                color: AppTheme.magma,
                size: 20,
              ),
            ),
            title: Text(
              entry.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            subtitle: Text(
              '${entry.operation} · ${Formatters.date(entry.createdAt)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.muted,
                fontSize: 10,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.muted,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyActivity(IconData icon, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 25,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.surfaceLight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.muted,
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(color: AppTheme.surfaceLight),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _navigate('/about'),
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.muted,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  'ABOUT ZIPPEDDON',
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'BUILT BY ANONYMOUS_BETA',
          style: TextStyle(
            color: AppTheme.toxic,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'CONTROLLED ARCHIVE RESEARCH & COMPRESSION',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.muted,
            fontSize: 8,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
