
import 'dart:io';

import 'package:archive/archive.dart';

class InspectedEntry {
  final String name;
  final int compressedSize;
  final int uncompressedSize;
  final bool isDirectory;

  const InspectedEntry({
    required this.name,
    required this.compressedSize,
    required this.uncompressedSize,
    required this.isDirectory,
  });

  double get expansionRatio {
    if (compressedSize == 0) return 0;
    return uncompressedSize / compressedSize;
  }
}

class ArchiveInspection {
  final String path;
  final int archiveSize;
  final int totalUncompressedSize;
  final List<InspectedEntry> entries;

  const ArchiveInspection({
    required this.path,
    required this.archiveSize,
    required this.totalUncompressedSize,
    required this.entries,
  });

  double get expansionRatio {
    if (archiveSize == 0) return 0;
    return totalUncompressedSize / archiveSize;
  }

  int get fileCount => entries.where((e) => !e.isDirectory).length;
}

class ExtractionLimits {
  final int maxFiles;
  final int maxTotalBytes;
  final int maxSingleFileBytes;
  final double maxExpansionRatio;

  const ExtractionLimits({
    this.maxFiles = 100,
    this.maxTotalBytes = 32 * 1024 * 1024,
    this.maxSingleFileBytes = 8 * 1024 * 1024,
    this.maxExpansionRatio = 100,
  });
}

class ExtractionLimitException implements Exception {
  final String message;

  const ExtractionLimitException(this.message);

  @override
  String toString() => message;
}

class ArchiveInspector {
  ArchiveInspection inspectFile(File file) {
    if (!file.existsSync()) {
      throw const FileSystemException('Archive does not exist');
    }

    final bytes = file.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);

    final entries = <InspectedEntry>[];
    var totalSize = 0;

    for (final item in archive.files) {
      final size = item.size;
      totalSize += size;

      entries.add(
        InspectedEntry(
          name: item.name,
          compressedSize: item.compressedSize,
          uncompressedSize: size,
          isDirectory: item.isDirectory,
        ),
      );
    }

    return ArchiveInspection(
      path: file.path,
      archiveSize: bytes.length,
      totalUncompressedSize: totalSize,
      entries: entries,
    );
  }

  void validateExtraction(
    ArchiveInspection inspection, {
    ExtractionLimits limits = const ExtractionLimits(),
  }) {
    if (inspection.fileCount > limits.maxFiles) {
      throw const ExtractionLimitException(
        'Archive contains more files than the configured limit.',
      );
    }

    if (inspection.totalUncompressedSize > limits.maxTotalBytes) {
      throw const ExtractionLimitException(
        'Archive exceeds the total extraction size limit.',
      );
    }

    if (inspection.expansionRatio > limits.maxExpansionRatio) {
      throw const ExtractionLimitException(
        'Archive exceeds the configured expansion ratio.',
      );
    }

    for (final entry in inspection.entries) {
      if (entry.uncompressedSize > limits.maxSingleFileBytes) {
        throw ExtractionLimitException(
          '${entry.name} exceeds the per-file extraction limit.',
        );
      }

      if (entry.name.startsWith('/') ||
          entry.name.contains('../') ||
          entry.name.contains(r'..\')) {
        throw ExtractionLimitException(
          'Unsafe archive path detected: ${entry.name}',
        );
      }
    }
  }

  Future<Directory> extractSafely(
    File archiveFile,
    Directory destination, {
    ExtractionLimits limits = const ExtractionLimits(),
  }) async {
    final inspection = inspectFile(archiveFile);
    validateExtraction(inspection, limits: limits);

    final bytes = await archiveFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);

    final root = await destination.create(recursive: true);
    final rootPath = root.absolute.path;

    for (final entry in archive.files) {
      final name = entry.name.replaceAll('\\', '/');

      if (name.startsWith('/') || name.split('/').contains('..')) {
        throw ExtractionLimitException(
          'Unsafe path rejected: $name',
        );
      }

      final output = File(
        '$rootPath${Platform.pathSeparator}$name',
      );

      final normalized = output.absolute.path;

      if (!normalized.startsWith(
        '$rootPath${Platform.pathSeparator}',
      )) {
        throw const ExtractionLimitException(
          'Archive entry attempted to leave the extraction directory.',
        );
      }

      if (entry.isDirectory) {
        await Directory(output.path).create(recursive: true);
        continue;
      }

      await output.parent.create(recursive: true);

      final content = entry.content;
      if (content is! List<int>) {
        throw ExtractionLimitException(
          'Unsupported entry data: $name',
        );
      }

      await output.writeAsBytes(content, flush: true);
    }

    return root;
  }
}
