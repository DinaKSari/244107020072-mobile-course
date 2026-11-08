import 'dart:async';

import '../../../../core/failures.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetPosts {
  GetPosts(this._repo);
  final PostRepository _repo;
  static const _cacheMaxAge = Duration(minutes: 5);
  Future<void>? _refreshInFlight;

  /// offline=true: hanya cache. Online: kembalikan cache seketika, refresh di
  /// background, panggil [onRefreshed] bila cache baru tersimpan.
  Future<Result<List<Post>>> call({
    bool offline = false,
    void Function()? onRefreshed,
  }) async {
    final cached = await _repo.readCache();
    if (!offline && await _repo.isCacheStale(maxAge: _cacheMaxAge)) {
      _refreshInFlight ??= _repo
          .refresh()
          .then<void>((r) {
            if (r.failure == null) onRefreshed?.call();
          })
          .whenComplete(() => _refreshInFlight = null);
      unawaited(_refreshInFlight!);
    }
    return cached;
  }
}
