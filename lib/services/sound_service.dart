
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  SoundService._();

  static final SoundService instance = SoundService._();

  final AudioPlayer _roarPlayer = AudioPlayer();
  final AudioPlayer _clickPlayer = AudioPlayer();

  bool enabled = true;

  Future<void> initialize() async {
    await _roarPlayer.setReleaseMode(ReleaseMode.stop);
    await _clickPlayer.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playRoar() async {
    if (!enabled) return;

    await _roarPlayer.stop();
    await _roarPlayer.play(
      AssetSource('audio/roar.mp3'),
    );
  }

  Future<void> playClick() async {
    if (!enabled) return;

    await _clickPlayer.stop();
    await _clickPlayer.play(
      AssetSource('audio/ui_click.mp3'),
    );
  }

  Future<void> dispose() async {
    await _roarPlayer.dispose();
    await _clickPlayer.dispose();
  }
}
