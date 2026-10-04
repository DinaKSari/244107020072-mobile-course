import 'package:dio/dio.dart';
import 'auth_repository.dart';
import 'token_store.dart';

const kApiBaseUrl = 'https://example-campus-api.test'; // ganti dengan API kampus

Dio buildApiClient(TokenStore store, AuthRepository auth, void Function() onExpired) {
  final dio = Dio(BaseOptions(baseUrl: kApiBaseUrl));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (o, h) async {
      final t = await store.readAccess();
      if (t != null) o.headers['Authorization'] = 'Bearer $t';
      h.next(o);
    },
    onError: (e, h) async {
      final req = e.requestOptions;
      if (e.response?.statusCode != 401 || req.extra['retried'] == true) {
        return h.next(e);
      }
      final refresh = await store.readRefresh();
      if (refresh == null) return h.next(e);

      final String access;
      try {
        access = await auth.refresh(refresh);
        await store.save(access: access, refresh: refresh);
      } catch (_) {
        await store.clear(); // refresh mati -> logout
        onExpired();
        return h.next(e);
      }
      req.extra['retried'] = true; // retry maksimal sekali
      req.headers['Authorization'] = 'Bearer $access';
      try {
        h.resolve(await dio.fetch(req));
      } on DioException catch (e2) {
        h.next(e2);
      }
    },
  ));
  return dio;
}