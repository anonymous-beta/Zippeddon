
import 'package:flutter_test/flutter_test.dart';

import 'package:zippeddon/core/config.dart';
import 'package:zippeddon/models/archive_config.dart';

void main() {
  group('ZIPPEDDON configuration', () {
    test('application identity is configured', () {
      expect(ZippeddonConfig.appName, 'ZIPPEDDON');
      expect(ZippeddonConfig.creator, 'Anonymous_beta');
    });

    test('valid archive configuration passes validation', () {
      const config = ArchiveConfig(
        filename: 'test_archive.zip',
        sampleBytes: 1024 * 1024,
        entryCount: 10,
        compressionLevel: 6,
        nestingDepth: 0,
      );

      expect(config.validate(), isEmpty);
    });

    test('archive configuration rejects oversized data', () {
      const config = ArchiveConfig(
        filename: 'oversized.zip',
        sampleBytes: 100 * 1024 * 1024,
        entryCount: 10,
        compressionLevel: 6,
        nestingDepth: 0,
      );

      expect(config.validate(), isNotEmpty);
    });

    test('archive configuration rejects excessive entries', () {
      const config = ArchiveConfig(
        filename: 'too_many.zip',
        sampleBytes: 1024 * 1024,
        entryCount: 101,
        compressionLevel: 6,
        nestingDepth: 0,
      );

      expect(config.validate(), isNotEmpty);
    });
  });
}
