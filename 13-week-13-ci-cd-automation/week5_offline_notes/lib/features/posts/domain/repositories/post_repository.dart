import '../../../../core/failures.dart';
import '../entities/post.dart';

abstract class PostRepository {
  Future<Result<List<Post>>> readCache();
  Future<Result<List<Post>>> refresh(); // fetch API + timpa cache
}