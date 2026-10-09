import 'package:ustachi/core/local/auth/auth_local_data_source.dart';
import 'package:ustachi/features/profile/data/master_profile_cache.dart';

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/singletons/storage/storage.dart';
import 'package:ustachi/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:ustachi/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:ustachi/features/profile/data/master_profile_api.dart';
import 'package:ustachi/features/profile/data/models/user_data_response.dart';
import 'package:ustachi/features/profile/data/repository/profile_repository_impl.dart';

UserDataResponse _response({String name = 'Usta Aka'}) => UserDataResponse(
      id: 7,
      phoneNumber: '+998901112233',
      fullName: name,
      roles: const ['client', 'master'],
      isMaster: true,
      isActive: true,
      dataJoined: '2026-01-01',
      photo: '',
      regionName: 'Toshkent',
      districtName: 'Yunusobod',
    );

class _Remote implements ProfileRemoteDataSource {
  _Remote({this.failure});

  Object? failure;
  UserDataResponse response = _response();
  int calls = 0;

  @override
  Future<UserDataResponse> getUserData() async {
    calls++;
    if (failure != null) throw failure!;
    return response;
  }
}

DioException get _offline => DioException.connectionError(
      requestOptions: RequestOptions(path: '/me'),
      reason: 'internet yo\'q',
    );

DioException _status(int code) => DioException.badResponse(
      statusCode: code,
      requestOptions: RequestOptions(path: '/me'),
      response: Response<dynamic>(
        statusCode: code,
        requestOptions: RequestOptions(path: '/me'),
      ),
    );

ProfileRepositoryImpl _repo(_Remote remote) => ProfileRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: ProfileLocalDataSource(),
    );

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    PackageInfo.setMockInitialValues(
      appName: 'Ustachi Pro',
      packageName: 'com.ustachi.pro',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    SharedPreferences.setMockInitialValues({});
    await StorageRepository.getInstance();
    await StorageRepository.clearStorage();
  });

  group('Profil — tarmoqsiz kirish', () {
    test('muvaffaqiyatli javob KESHGA yoziladi', () async {
      final remote = _Remote();

      await _repo(remote).getUserData();

      final cached = ProfileLocalDataSource().getCached();
      expect(cached, isNotNull);
      expect(cached!.fullName, 'Usta Aka');
      expect(cached.isMaster, isTrue);
    });

    test('TARMOQ YIQILSA kesh qaytadi — ilovaga kirish ochiq', () async {

      final remote = _Remote();
      await _repo(remote).getUserData(); 

      remote.failure = _offline;
      final result = await _repo(remote).getUserData();

      expect(result.isRight, isTrue, reason: 'xato emas, kesh qaytishi kerak');
      expect(result.right.fullName, 'Usta Aka');
    });

    test('KESH YO\'Q bo\'lsa xato qaytadi', () async {

      final result = await _repo(_Remote(failure: _offline)).getUserData();

      expect(result.isLeft, isTrue);
    });

    test('401 da kesh ISHLATILMAYDI — kirish ekraniga chiqiladi', () async {

      final remote = _Remote();
      await _repo(remote).getUserData();

      remote.failure = _status(401);
      final result = await _repo(remote).getUserData();

      expect(result.isLeft, isTrue);
      expect((result.left as ServerFailure).statusCode, 401);
    });

    test('403 da ham kesh ishlatilmaydi', () async {
      final remote = _Remote();
      await _repo(remote).getUserData();

      remote.failure = _status(403);
      expect((await _repo(remote).getUserData()).isLeft, isTrue);
    });

    test('SERVER XATOSIDA (500) kesh qaytadi', () async {

      final remote = _Remote();
      await _repo(remote).getUserData();

      remote.failure = _status(500);
      expect((await _repo(remote).getUserData()).isRight, isTrue);
    });

    test('keyingi muvaffaqiyat keshni YANGILAYDI', () async {
      final remote = _Remote();
      await _repo(remote).getUserData();

      remote.response = _response(name: 'Yangi Ism');
      await _repo(remote).getUserData();

      expect(ProfileLocalDataSource().getCached()!.fullName, 'Yangi Ism');
    });

    test('LOGOUT keshni o\'chiradi', () async {
      final local = ProfileLocalDataSource();
      await _repo(_Remote()).getUserData();
      expect(local.getCached(), isNotNull);

      await local.clear();

      expect(local.getCached(), isNull,
          reason: 'boshqa hisob eski profilni ko\'rmasin');
    });
  });

  group('Kasbiy profil — «yo\'q» va «yetib bo\'lmadi» AJRATILADI', () {

    Dio dioThatFails(DioException error) {
      final dio = Dio();
      dio.httpClientAdapter = _FailingAdapter(error);
      return dio;
    }

    test('404 — profil HAQIQATAN yo\'q, server javob berdi', () async {
      final api = MasterProfileApi(dioThatFails(_status(404)));

      final result = await api.readWithStatus();

      expect(result.data, isNull);
      expect(result.reachable, isTrue,
          reason: 'server javob berdi — kasbiy forma ochilishi mumkin');
    });

    test('TARMOQ YO\'Q — profil noma\'lum, forma OCHILMASLIGI kerak', () async {
      final api = MasterProfileApi(dioThatFails(_offline));

      final result = await api.readWithStatus();

      expect(result.reachable, isFalse);
    });

    test('onboarding auth rejection must not reuse a complete cache', () async {
      await MasterProfileCache().save({'specialty': 1, 'experience_years': 0});
      for (final code in [401, 403]) {
        final api = MasterProfileApi(dioThatFails(_status(code)));
        await expectLater(api.readWithStatus(rejectUnauthorized: true),
            throwsA(isA<DioException>()));
      }
    });

    test('complete cached professional profile remains usable offline',
        () async {
      await MasterProfileCache().save({'specialty': 1, 'experience_years': 0});
      final api = MasterProfileApi(dioThatFails(_offline));
      final result = await api.readWithStatus(rejectUnauthorized: true);
      expect(result.reachable, isFalse);
      expect(result.data?.isComplete, isTrue);
    });

    test('clearing auth removes both account profile caches', () async {
      await _repo(_Remote()).getUserData();
      await MasterProfileCache().save({'specialty': 1, 'experience_years': 0});
      await AuthLocalDataSource().clearUserData();
      expect(ProfileLocalDataSource().getCached(), isNull);
      expect(MasterProfileCache().read(), isNull);
    });

    test('500 ham «yetib bo\'lmadi» deb hisoblanadi', () async {
      final api = MasterProfileApi(dioThatFails(_status(500)));

      expect((await api.readWithStatus()).reachable, isFalse);
    });
  });

}

class _FailingAdapter implements HttpClientAdapter {
  _FailingAdapter(this.error);

  final DioException error;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream,
          Future<void>? cancelFuture) =>
      Future<ResponseBody>.error(error);

  @override
  void close({bool force = false}) {}
}
