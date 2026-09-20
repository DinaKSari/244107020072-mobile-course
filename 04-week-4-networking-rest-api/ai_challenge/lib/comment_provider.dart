import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/comment_model.dart';
import '/comment_repository.dart';

// 1. Provider untuk inisialisasi instance Dio
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
});

// 2. Provider untuk inisialisasi Repository
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository(ref.watch(dioProvider));
});

// 3. Menggunakan AsyncNotifier biasa (mengatasi error extends_non_class)
class CommentNotifier extends AsyncNotifier<List<Comment>> {
  
  // Tangkap argumen melalui variabel dan constructor
  final int postId;
  CommentNotifier(this.postId);

  // Method build() bawaan AsyncNotifier tidak menerima argumen (mengatasi override error)
  @override
  FutureOr<List<Comment>> build() async {
    return _fetchComments(postId);
  }

  Future<List<Comment>> _fetchComments(int id) async {
    final repository = ref.read(commentRepositoryProvider);
    return await repository.fetchComments(id);
  }
  
  Future<void> refresh() async {
    // state dan ref otomatis tersedia jika extends AsyncNotifier sukses dikenali
    state = const AsyncLoading(); 
    state = await AsyncValue.guard(() => _fetchComments(postId));
  }
}

// 4. Provider yang diekspos ke UI
// Mengatasi error argument_type_not_assignable dengan memberikan Function(int) 
final commentNotifierProvider = AsyncNotifierProvider.family<CommentNotifier, List<Comment>, int>(
  (int id) => CommentNotifier(id), 
);