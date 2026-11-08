import '../../../../core/failures.dart';
import '../entities/post.dart';

abstract class PostRepository {
  Future<Result<List<Post>>> readCache();
  Future<bool> isCacheStale({required Duration maxAge});
  Future<Result<List<Post>>> refresh(); // fetch API + timpa cache
}
