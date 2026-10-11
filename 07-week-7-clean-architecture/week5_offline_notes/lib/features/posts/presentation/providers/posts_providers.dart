import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/failures.dart';
import '../../../../shared/db.dart';
import '../../../../shared/providers.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/get_posts.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) =>
    PostRepositoryImpl(dio: ref.watch(dioProvider), openDb: openNotesDb));

final getPostsProvider =
    Provider((ref) => GetPosts(ref.watch(postRepositoryProvider)));

class PostListNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final r = await ref.watch(getPostsProvider).call(
          offline: ref.watch(forceOfflineProvider),
          onRefreshed: () => ref.invalidateSelf(),
        );
    return r.orThrow;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final repo = ref.read(postRepositoryProvider);
    final r = ref.read(forceOfflineProvider)
        ? await repo.readCache()
        : await repo.refresh();
    state = r.failure != null
        ? AsyncError(r.failure!, StackTrace.current)
        : AsyncData(r.data!);
  }
}

final postListProvider = AsyncNotifierProvider<PostListNotifier, List<Post>>(
    PostListNotifier.new,
    retry: (retryCount, error) => null);