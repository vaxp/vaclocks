import 'package:just_audio/just_audio.dart';

class Ringer {
  Ringer._();
  static final Ringer _instance = Ringer._();
  factory Ringer() => _instance;

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  Future<void> start({String assetPath = 'Sound/alarm.mp3'}) async {
    if (_isPlaying) return;
    _isPlaying = true;
    try {
      await _player.setAudioSource(AudioSource.asset(assetPath));
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(1.0);
      await _player.play();
    } catch (e) {
      _isPlaying = false;
      // ignore: avoid_print
      print('Failed to play alarm asset "$assetPath" with just_audio: $e');
    }
  }

  Future<void> stop() async {
    _isPlaying = false;
    try {
      await _player.stop();
    } catch (_) {}
  }
}


