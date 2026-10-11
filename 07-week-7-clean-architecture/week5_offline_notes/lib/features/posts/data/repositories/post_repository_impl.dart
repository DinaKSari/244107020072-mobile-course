import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/post_model.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({required Dio dio, required Future<Database> Function() openDb})
      : _dio = dio,
        _openDb = openDb;
  final Dio _dio;
  final Future<Database> Function() _openDb;

  @override
  Future<Result<List<Post>>> readCache() async {
    try {
      final db = await _openDb();
      final rows = await db.query('cached_posts', orderBy: 'id ASC');
      final posts = rows
          .map((r) => PostModel.fromJson(
              jsonDecode(r['payload'] as String) as Map<String, dynamic>))
          .toList();
      return (data: posts, failure: null);
    } catch (_) {
      return (data: null, failure: const LocalFailure('Gagal membaca cache.'));
    }
  }

  @override
  Future<Result<List<Post>>> refresh() async {
    try {
      final res = await _dio.get<List>('/posts');
      final posts = (res.data ?? [])
          .whereType<Map<String, dynamic>>()
          .map(PostModel.fromJson)
          .toList();
      final db = await _openDb();
      await db.transaction((txn) async {
        await txn.delete('cached_posts');
        final now = DateTime.now().toIso8601String();
        for (final p in posts) {
          await txn.insert('cached_posts', {
            'id': p.id,
            'payload': jsonEncode(p.toJson()),
            'cached_at': now,
          });
        }
      });
      return (data: posts, failure: null);
    } on DioException catch (e) {
      return (data: null, failure: NetworkFailure(friendlyErrorMessage(e)));
    } catch (_) {
      return (data: null, failure: const LocalFailure('Gagal menyimpan cache.'));
    }
  }
}

String friendlyErrorMessage(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Koneksi lambat atau timeout. Periksa internet Anda lalu coba lagi.';
    case DioExceptionType.connectionError:
      return 'Tidak dapat terhubung ke server. Periksa internet Anda.';
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode;
      if (code == 404) return 'Data tidak ditemukan (404).';
      if (code == 401 || code == 403) {
        return 'Akses ditolak ($code). Periksa kredensial Anda.';
      }
      return 'Server bermasalah ($code). Coba lagi nanti.';
    default:
      return 'Terjadi kesalahan jaringan. Coba lagi.';
  }
}