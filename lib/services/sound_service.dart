import 'package:audioplayers/audioplayers.dart';

/// A singleton service for playing sound effects throughout the app.
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();

  // Sound asset paths
  static const String _soundsPath = 'sounds/';

  /// Play camera sound (analysis/scan)
  Future<void> playCamera() => _play('camera.mp3');

  /// Play click sound (isolation/interaction)
  Future<void> playClick() => _play('click.mp3');

  /// Play success chime (save clothing, create outfit)
  Future<void> playSuccess() => _play('success.mp3');

  /// Play pop sound (like, toggle)
  Future<void> playPop() => _play('pop.mp3');

  /// Play trash sound (delete)
  Future<void> playTrash() => _play('trash.mp3');

  /// Internal method to play a sound file
  Future<void> _play(String fileName) async {
    try {
      await _player.stop(); // Stop any currently playing sound
      await _player.play(AssetSource('$_soundsPath$fileName'));
    } catch (e) {
      print('SoundService: Error playing $fileName: $e');
    }
  }

  /// Dispose the player when no longer needed
  void dispose() {
    _player.dispose();
  }
}
