
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/profile/domain/models/user_model.dart';
import 'package:ustachi/features/profile/presentation/widgets/user_avatar_widget.dart';

UserModel _user({String photo = '', String name = 'Aziz Karimov'}) => UserModel(
      id: 1,
      phoneNumber: '+998901234567',
      fullName: name,
      roles: const ['master'],
      isMaster: true,
      isActive: true,
      dataJoined: '',
      photo: photo,
      regionName: '',
      districtName: '',
      address: '',
    );

Future<void> _pump(WidgetTester tester, UserModel user,
    {VoidCallback? onEdit}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(428, 926),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, __) => MaterialApp(
      home: Scaffold(
        body: UserAvatarWidget(userModel: user, onEdit: onEdit),
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  test('KODDA tasodifiy rasm manzili QOLMAGAN', () {

    const path = 'lib/features/profile/presentation/widgets/user_avatar_widget.dart';
    final source = File(path).readAsStringSync();

    final code = source
        .split('\n')
        .where((line) => !line.trimLeft().startsWith('//'))
        .join('\n');

    expect(code.contains('picsum.photos'), isFalse,
        reason: 'tasodifiy rasm manzili KODDA qolgan');
    expect(code.contains('userModel.photo'), isTrue,
        reason: 'haqiqiy rasm ishlatilmayapti');
  });

  testWidgets('rasm BOR bo\'lsa tarmoqdan yuklanadi', (tester) async {
    await _pump(
      tester,
      _user(photo: 'https://ustachi.uz/media/users/photos/a.jpg'),
    );

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.imageUrl, 'https://ustachi.uz/media/users/photos/a.jpg');
  });

  testWidgets('rasm YO\'Q bo\'lsa ism bosh harfi', (tester) async {
    await _pump(tester, _user());

    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('ismsiz foydalanuvchida ham bo\'sh doira qolmaydi',
      (tester) async {
    await _pump(tester, _user(name: ''));
    expect(find.text('7'), findsOneWidget); 
  });

  testWidgets('qalam belgisi BOSILADI (bezak emas)', (tester) async {
    var tapped = false;
    await _pump(tester, _user(), onEdit: () => tapped = true);

    await tester.tap(find.byIcon(Icons.edit));
    expect(tapped, isTrue);
  });

  testWidgets('onEdit berilmasa qalam umuman chizilmaydi', (tester) async {
    await _pump(tester, _user());
    expect(find.byIcon(Icons.edit), findsNothing);
  });
}
