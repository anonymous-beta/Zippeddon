
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class StorageService {
  Future<Directory> archiveDirectory() async {
    final root = await getApplicationDocumentsDirectory();

    final directory = Directory(
      '${root.path}/ZIPPEDDON/archives',
    );

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  Future<List<FileSystemEntity>> listArchives() async {
    final directory = await archiveDirectory();

    return directory
        .listSync()
        .whereType<File>()
        .where(
          (file) =>
              file.path.toLowerCase().endsWith('.zip'),
        )
        .toList();
  }

  Future<bool> deleteArchive(String path) async {
    final directory = await archiveDirectory();

    final file = File(path);

    if (!file.path.startsWith(directory.path)) {
      throw ArgumentError(
        'File is outside the archive directory.',
      );
    }

    if (!await file.exists()) return false;

    await file.delete();

    return true;
  }

  Future<int> totalArchiveBytes() async {
    final files = await listArchives();

    int total = 0;

    for (final entity in files) {
      total += await (entity as File).length();
    }

    return total;
  }
}
