
import 'dart:io';

import 'package:share_plus/share_plus.dart';

class ShareService {
  Future<void> shareArchive(String path) async {
    final file = File(path);

    if (!await file.exists()) {
      throw StateError('Archive does not exist.');
    }

    if (!path.toLowerCase().endsWith('.zip')) {
      throw ArgumentError('Only ZIP files are supported.');
    }

    await Share.shareXFiles(
      [
        XFile(
          file.path,
          mimeType: 'application/zip',
        ),
      ],
      subject: 'ZIPPEDDON Archive',
      text: 'Created using ZIPPEDDON by Anonymous_beta.',
    );
  }
}
