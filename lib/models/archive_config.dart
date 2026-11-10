
class ArchiveConfig {
  final String filename;
  final int sampleBytes;
  final int entryCount;
  final int compressionLevel;
  final int nestingDepth;

  const ArchiveConfig({
    required this.filename,
    required this.sampleBytes,
    required this.entryCount,
    required this.compressionLevel,
    required this.nestingDepth,
  });

  ArchiveConfig copyWith({
    String? filename,
    int? sampleBytes,
    int? entryCount,
    int? compressionLevel,
    int? nestingDepth,
  }) {
    return ArchiveConfig(
      filename: filename ?? this.filename,
      sampleBytes: sampleBytes ?? this.sampleBytes,
      entryCount: entryCount ?? this.entryCount,
      compressionLevel:
          compressionLevel ?? this.compressionLevel,
      nestingDepth: nestingDepth ?? this.nestingDepth,
    );
  }

  Map<String, dynamic> toJson() => {
    'filename': filename,
    'sampleBytes': sampleBytes,
    'entryCount': entryCount,
    'compressionLevel': compressionLevel,
    'nestingDepth': nestingDepth,
  };

  factory ArchiveConfig.fromJson(
    Map<String, dynamic> json,
  ) {
    return ArchiveConfig(
      filename: json['filename'] as String,
      sampleBytes: json['sampleBytes'] as int,
      entryCount: json['entryCount'] as int,
      compressionLevel: json['compressionLevel'] as int,
      nestingDepth: json['nestingDepth'] as int,
    );
  }

  String validate() {
    if (filename.trim().isEmpty) {
      return 'Filename cannot be empty.';
    }

    if (sampleBytes < 1024 ||
        sampleBytes > 8 * 1024 * 1024) {
      return 'Sample size must be between 1 KiB and 8 MiB.';
    }

    if (entryCount < 1 || entryCount > 100) {
      return 'Entry count must be between 1 and 100.';
    }

    if (compressionLevel < 0 ||
        compressionLevel > 9) {
      return 'Compression level must be between 0 and 9.';
    }

    if (nestingDepth < 0 || nestingDepth > 3) {
      return 'Nesting depth must be between 0 and 3.';
    }

    return '';
  }
}
