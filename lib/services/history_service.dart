
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/history_entry.dart';

class HistoryService {
  static const String _historyFileName = 'zippeddon_history.json';

  Future<File> _historyFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_historyFileName');
  }

  Future<List<HistoryEntry>> getEntries() async {
    final file = await _historyFile();

    if (!await file.exists()) {
      return [];
    }

    try {
      final decoded = jsonDecode(await file.readAsString());

      if (decoded is! List) return [];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(HistoryEntry.fromJson)
          .toList()
        ..sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        );
    } catch (_) {
      return [];
    }
  }

  Future<void> addEntry(HistoryEntry entry) async {
    final entries = await getEntries();

    entries.removeWhere((item) => item.id == entry.id);
    entries.insert(0, entry);

    final limited = entries.take(200).toList();

    final file = await _historyFile();
    await file.writeAsString(
      jsonEncode(limited.map((item) => item.toJson()).toList()),
      flush: true,
    );
  }

  Future<void> deleteEntry(String id) async {
    final entries = await getEntries();
    entries.removeWhere((entry) => entry.id == id);

    final file = await _historyFile();
    await file.writeAsString(
      jsonEncode(entries.map((entry) => entry.toJson()).toList()),
      flush: true,
    );
  }

  Future<void> clear() async {
    final file = await _historyFile();

    if (await file.exists()) {
      await file.delete();
    }
  }
}
