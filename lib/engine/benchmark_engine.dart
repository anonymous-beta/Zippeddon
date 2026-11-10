
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';

class BenchmarkResult {
  final int originalSize;
  final int compressedSize;
  final Duration compressionTime;
  final Duration decompressionTime;
  final bool integrityVerified;

  const BenchmarkResult({
    required this.originalSize,
    required this.compressedSize,
    required this.compressionTime,
    required this.decompressionTime,
    required this.integrityVerified,
  });

  double get ratio =>
      compressedSize == 0
          ? 0
          : originalSize / compressedSize;

  double get compressionSpeed {
    final seconds =
        compressionTime.inMicroseconds / 1000000;

    if (seconds <= 0) return 0;

    return originalSize / seconds / 1024 / 1024;
  }
}

class BenchmarkEngine {
  static const int maxBytes = 4 * 1024 * 1024;

  Future<BenchmarkResult> run({
    required int bytes,
    required int seed,
  }) async {
    if (bytes < 1024 || bytes > maxBytes) {
      throw ArgumentError(
        'Benchmark size must be between 1 KiB and 4 MiB.',
      );
    }

    final source = Uint8List(bytes);

    final random = Random(seed);

    for (int i = 0; i < source.length; i++) {
      source[i] = random.nextInt(256);
    }

    final archive = Archive();

    archive.addFile(
      ArchiveFile(
        'benchmark/random-data.bin',
        source.length,
        source,
      ),
    );

    final compressionWatch = Stopwatch()..start();

    final encoded = ZipEncoder().encode(archive);

    compressionWatch.stop();

    if (encoded == null || encoded.isEmpty) {
      throw StateError('Compression benchmark failed.');
    }

    final decompressionWatch = Stopwatch()..start();

    final decoded = ZipDecoder().decodeBytes(
      encoded,
      verify: true,
    );

    decompressionWatch.stop();

    final entry = decoded.findFile(
      'benchmark/random-data.bin',
    );

    if (entry == null) {
      throw StateError('Benchmark entry missing.');
    }

    final restored = entry.content as List<int>;

    bool verified = restored.length == source.length;

    if (verified) {
      for (int i = 0; i < source.length; i++) {
        if (source[i] != restored[i]) {
          verified = false;
          break;
        }
      }
    }

    return BenchmarkResult(
      originalSize: source.length,
      compressedSize: encoded.length,
      compressionTime: compressionWatch.elapsed,
      decompressionTime: decompressionWatch.elapsed,
      integrityVerified: verified,
    );
  }
}
