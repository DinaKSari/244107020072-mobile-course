import 'dart:async';
import '../../../../core/failures.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetPosts {
  const GetPosts(this._repo);
  final PostRepository _repo;

  /// offline=true: hanya cache. Online: kembalikan cache seketika, refresh di
  /// background, panggil [onRefreshed] bila cache baru tersimpan.
  Future<Result<List<Post>>> call(
      {bool offline = false, void Function()? onRefreshed}) async {
    final cached = await _repo.readCache();
    if (!offline) {
      unawaited(_repo.refresh().then((r) {
        if (r.failure == null) onRefreshed?.call();
      }));
    }
    return cached;
  }
}