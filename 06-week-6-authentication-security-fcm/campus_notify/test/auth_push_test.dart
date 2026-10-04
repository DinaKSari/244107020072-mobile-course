import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/routes.dart';

void main() {
  test('routeFromMessage: kosong, tanpa slash, dan normal', () {
    expect(routeFromMessage({}), '/');
    expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
    expect(routeFromMessage({'route': '/pengumuman/3', 'id': '3'}), '/pengumuman/3');
    expect(Routes.announcementOf('3'), '/pengumuman/3');
  });

  test('sesi: token tersimpan lalu clear() memaksa login ulang', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final store = TokenStore();
    await store.save(access: 'a', refresh: 'r');
    expect(await store.readAccess(), 'a');
    expect(await store.readRefresh(), 'r');
    await store.clear();
    expect(await store.readAccess(), isNull);
  });

  test('friendlyError memetakan DioException', () {
    final req = RequestOptions(path: '/x');
    DioException err(DioExceptionType t, [int? code]) => DioException(
          requestOptions: req,
          type: t,
          response: code == null ? null : Response(requestOptions: req, statusCode: code),
        );
    expect(friendlyError(err(DioExceptionType.connectionTimeout)), contains('timeout'));
    expect(friendlyError(err(DioExceptionType.connectionError)), contains('internet'));
    expect(friendlyError(err(DioExceptionType.badResponse, 401)), contains('login ulang'));
    expect(friendlyError(Exception('Email tidak valid')), 'Email tidak valid');
  });
}