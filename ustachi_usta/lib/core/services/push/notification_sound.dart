import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NotificationSound {
  NotificationSound({AudioPlayer? player}) : _player = player;

  AudioPlayer? _player;

  AudioPlayer get _audio =>
      _player ??= AudioPlayer(playerId: 'ustachi_notification');

  static const _minGap = Duration(milliseconds: 1200);
  DateTime? _lastPlayedAt;

  Future<void> play({DateTime Function() clock = DateTime.now}) async {
    final now = clock();
    final last = _lastPlayedAt;
    if (last != null && now.difference(last) < _minGap) return;
    _lastPlayedAt = now;

    unawaited(HapticFeedback.mediumImpact());

    try {
      final audio = _audio;
      await audio.stop();
      await audio.play(
        AssetSource('sounds/notification.mp3'),
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      debugPrint('[push] ohang chalinmadi: $e');
    }
  }

  Future<void> dispose() async => _player?.dispose();
}
