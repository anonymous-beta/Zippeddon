
class HistoryEntry {
  final String id;
  final String fileName;
  final String filePath;
  final int archiveSize;
  final int uncompressedSize;
  final int fileCount;
  final DateTime createdAt;
  final String operation;

  const HistoryEntry({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.archiveSize,
    required this.uncompressedSize,
    required this.fileCount,
    required this.createdAt,
    required this.operation,
  });

  double get compressionRatio {
    if (archiveSize == 0) return 0;
    return uncompressedSize / archiveSize;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'filePath': filePath,
        'archiveSize': archiveSize,
        'uncompressedSize': uncompressedSize,
        'fileCount': fileCount,
        'createdAt': createdAt.toIso8601String(),
        'operation': operation,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      archiveSize: json['archiveSize'] as int,
      uncompressedSize: json['uncompressedSize'] as int,
      fileCount: json['fileCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      operation: json['operation'] as String,
    );
  }
}
