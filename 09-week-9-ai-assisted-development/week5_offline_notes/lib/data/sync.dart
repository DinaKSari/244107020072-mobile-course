import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'models/post.dart';
import 'repositories/post_repository.dart';
import 'local/db.dart';
import 'repositories/note_repository.dart';

// ---- Cache posts (cache-first read untuk data API) ----

/// Baca cache lokal dari tabel cached_posts
Future<List<Post>> readCachedPosts(
    {Future<Database> Function()? openDb}) async {
  final db = await (openDb ?? openNotesDb)();
  final rows = await db.query('cached_posts', orderBy: 'id ASC');
  return rows
      .map((row) => Post.fromJson(
          jsonDecode(row['payload'] as String) as Map<String, dynamic>))
      .toList();
}

/// Timpa cache lama dengan hasil fetch terbaru
Future<void> writeCachedPosts(List<Post> posts,
    {Future<Database> Function()? openDb}) async {
  final db = await (openDb ?? openNotesDb)();
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

/// Cache-first: kembalikan cache seketika, refresh dari network di
/// background, lalu panggil [onRefreshed] setelah cache baru tersimpan.
Future<List<Post>> loadPostsCacheFirst(
  PostRepository repository, {
  void Function(List<Post> fresh)? onRefreshed,
  Future<Database> Function()? openDb,
}) async {
  final cached = await readCachedPosts(openDb: openDb);
  unawaited(_refreshPostsInBackground(repository, onRefreshed, openDb));
  return cached;
}

Future<void> _refreshPostsInBackground(
  PostRepository repository,
  void Function(List<Post> fresh)? onRefreshed,
  Future<Database> Function()? openDb,
) async {
  try {
    final fresh = await repository.fetchPosts();
    await writeCachedPosts(fresh, openDb: openDb);
    onRefreshed?.call(fresh);
  } catch (_) {
    // Offline/gagal fetch: cache lama tetap dipakai.
  }
}

// ---- Sinkronisasi catatan dirty ----

/// Simulasi upload catatan dirty ke server. Pada project nyata, kirim
/// tiap catatan dirty ke REST API di sini, lalu tandai bersih bila
/// server menjawab 2xx.
Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}