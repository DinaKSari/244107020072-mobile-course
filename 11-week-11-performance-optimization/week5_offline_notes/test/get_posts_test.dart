import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/core/failures.dart';
import 'package:week5_offline_notes/features/posts/domain/entities/post.dart';
import 'package:week5_offline_notes/features/posts/domain/repositories/post_repository.dart';
import 'package:week5_offline_notes/features/posts/domain/usecases/get_posts.dart';

class FakePostRepository implements PostRepository {
  FakePostRepository({required this.stale, required this.refreshResult});

  final bool stale;
  final Completer<Result<List<Post>>> refreshResult;
  int refreshCalls = 0;

  @override
  Future<Result<List<Post>>> readCache() async =>
      (data: const <Post>[], failure: null);

  @override
  Future<bool> isCacheStale({required Duration maxAge}) async => stale;

  @override
  Future<Result<List<Post>>> refresh() {
    refreshCalls++;
    return refreshResult.future;
  }
}

void main() {
  test('fresh cache does not trigger an API refresh', () async {
    final repo = FakePostRepository(
      stale: false,
      refreshResult: Completer<Result<List<Post>>>(),
    );

    await GetPosts(repo).call();

    expect(repo.refreshCalls, 0);
  });

  test('stale cache triggers only one background refresh', () async {
    final refreshResult = Completer<Result<List<Post>>>();
    final repo = FakePostRepository(stale: true, refreshResult: refreshResult);
    final useCase = GetPosts(repo);

    await Future.wait([useCase.call(), useCase.call()]);
    expect(repo.refreshCalls, 1);

    refreshResult.complete((data: const <Post>[], failure: null));
  });
}
