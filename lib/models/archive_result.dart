
class ArchiveResult {
  final String filename;
  final String path;
  final int originalBytes;
  final int compressedBytes;
  final int entryCount;
  final Duration elapsed;
  final String checksum;
  final DateTime createdAt;

  const ArchiveResult({
    required this.filename,
    required this.path,
    required this.originalBytes,
    required this.compressedBytes,
    required this.entryCount,
    required this.elapsed,
    required this.checksum,
    required this.createdAt,
  });

  double get compressionRatio {
    if (compressedBytes == 0) return 0;

    return originalBytes / compressedBytes;
  }

  double get savedPercentage {
    if (originalBytes == 0) return 0;

    return (1 - compressedBytes / originalBytes) * 100;
  }

  Map<String, dynamic> toJson() => {
    'filename': filename,
    'path': path,
    'originalBytes': originalBytes,
    'compressedBytes': compressedBytes,
    'entryCount': entryCount,
    'elapsedMs': elapsed.inMilliseconds,
    'checksum': checksum,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ArchiveResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return ArchiveResult(
      filename: json['filename'],
      path: json['path'],
      originalBytes: json['originalBytes'],
      compressedBytes: json['compressedBytes'],
      entryCount: json['entryCount'],
      elapsed: Duration(
        milliseconds: json['elapsedMs'],
      ),
      checksum: json['checksum'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
