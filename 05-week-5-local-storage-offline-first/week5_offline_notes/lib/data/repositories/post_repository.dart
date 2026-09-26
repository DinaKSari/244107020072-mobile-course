import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import '../local/db.dart';
import '../models/post.dart';

class PostRepository {
  PostRepository(this._dio, {Future<Database> Function()? openDb})
      : _openDb = openDb ?? openNotesDb;

  final Dio _dio;
  final Future<Database> Function() _openDb;

  Future<List<Post>> fetchPosts() async {
    final response = await _dio.get<List>('/posts');
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();
  }

  // Baca cache lokal dari tabel cached_posts
  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows
        .map((row) => Post.fromJson(
            jsonDecode(row['payload'] as String) as Map<String, dynamic>))
        .toList();
  }

  // Timpa cache lama dengan hasil fetch terbaru
  Future<void> writeCachedPosts(List<Post> posts) async {
    final db = await _openDb();
    await db.transaction((txn) async {
      await txn.delete('cached_posts');
      final now = DateTime.now().toIso8601String();
      for (final post in posts) {
        await txn.insert('cached_posts', {
          'id': post.id,
          'payload': jsonEncode(post.toJson()),
          'cached_at': now,
        });
      }
    });
  }

  /// Cache-first: kembalikan cache seketika, lalu refresh dari network
  /// di background tanpa memblokir. [onRefreshed] dipanggil setelah
  /// data baru berhasil disimpan ke cache.
  Future<List<Post>> loadPostsCacheFirst({
    void Function(List<Post> fresh)? onRefreshed,
  }) async {
    final cached = await readCachedPosts();
    unawaited(_refreshInBackground(onRefreshed));
    return cached;
  }

  Future<void> _refreshInBackground(
      void Function(List<Post> fresh)? onRefreshed) async {
    try {
      final fresh = await fetchPosts();
      await writeCachedPosts(fresh);
      onRefreshed?.call(fresh);
    } catch (_) {
      // Offline/gagal fetch: cache lama tetap dipakai, tidak perlu error.
    }
  }
}