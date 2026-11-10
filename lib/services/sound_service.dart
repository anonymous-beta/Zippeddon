
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  SoundService._();

  static final SoundService instance = SoundService._();

  final AudioPlayer _roarPlayer = AudioPlayer();

  bool enabled = true;

  Future<void> initialize() async {
    await _roarPlayer.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playRoar() async {
    if (!enabled) return;

    try {
      await _roarPlayer.stop();
      await _roarPlayer.play(
        AssetSource('audio/roar.mp3'),
      );
    } catch (_) {
      // Audio is optional; do not interrupt app functionality.
    }
  }

  Future<void> playClick() async {
    // Optional click audio is not bundled yet.
    // Deliberately silent until a real audio asset is supplied.
  }

  Future<void> dispose() async {
    await _roarPlayer.dispose();
  }
}
