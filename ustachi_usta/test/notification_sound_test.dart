
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/core/services/push/notification_sound.dart';

class _FakePlayer implements AudioPlayer {
  final played = <String>[];
  int stops = 0;
  bool disposed = false;
  Object? failWith;

  @override
  Future<void> play(Source source, {double? volume, double? balance,
      AudioContext? ctx, Duration? position, PlayerMode? mode}) async {
    if (failWith != null) throw failWith!;
    played.add((source as AssetSource).path);
  }

  @override
  Future<void> stop() async => stops++;

  @override
  Future<void> dispose() async => disposed = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('KANALDAGI ohangning AYNI nusxasi chalinadi', () async {

    final player = _FakePlayer();
    await NotificationSound(player: player).play();

    expect(player.played, ['sounds/notification.mp3']);
  });

  test('KETMA-KET xabarlar ovozni ustma-ust QO\'YMAYDI', () async {
    final player = _FakePlayer();
    final sound = NotificationSound(player: player);
    var now = DateTime(2026, 9, 5, 12);

    await sound.play(clock: () => now);
    now = now.add(const Duration(milliseconds: 300));
    await sound.play(clock: () => now);

    expect(player.played, hasLength(1), reason: 'ikkinchisi o\'tkazib yuborildi');
  });

  test('bir soniyadan keyin YANA chalinadi', () async {
    final player = _FakePlayer();
    final sound = NotificationSound(player: player);
    var now = DateTime(2026, 9, 5, 12);

    await sound.play(clock: () => now);
    now = now.add(const Duration(seconds: 2));
    await sound.play(clock: () => now);

    expect(player.played, hasLength(2));
  });

  test('OVOZ CHALINMASA xato tashqariga chiqmaydi', () async {

    final player = _FakePlayer()..failWith = Exception('audio fokus band');

    await NotificationSound(player: player).play();  
  });

  test('oldingi ovoz TO\'XTATILADI (ustiga chiqmasin)', () async {
    final player = _FakePlayer();
    await NotificationSound(player: player).play();

    expect(player.stops, 1);
  });

  test('dispose pleyerni yopadi', () async {
    final player = _FakePlayer();
    await NotificationSound(player: player).dispose();

    expect(player.disposed, isTrue);
  });
}
