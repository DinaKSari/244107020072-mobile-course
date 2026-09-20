import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../comment_provider.dart';

// Gunakan ConsumerWidget agar bisa menggunakan 'ref' di dalam build method
class CommentPage extends ConsumerWidget {
  final int postId;

  const CommentPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memantau state dari provider dengan argumen postId
    final commentState = ref.watch(commentNotifierProvider(postId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Komentar (Post #$postId)'),
        actions: [
          // Tombol manual untuk refresh data
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(commentNotifierProvider(postId).notifier).refresh();
            },
          )
        ],
      ),
      // .when() secara elegan menangani ketiga kondisi Asynchronous
      body: commentState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                // Menampilkan pesan error ramah pengguna yang kita buat di repository
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Memanggil fungsi refresh jika terjadi error
                    ref.read(commentNotifierProvider(postId).notifier).refresh();
                  },
                  child: const Text('Coba Lagi'),
                )
              ],
            ),
          ),
        ),
        data: (comments) {
          if (comments.isEmpty) {
            return const Center(child: Text('Tidak ada komentar.'));
          }

          // Render List komentar jika data berhasil dimuat
          return RefreshIndicator(
            onRefresh: () => ref.read(commentNotifierProvider(postId).notifier).refresh(),
            child: ListView.separated(
              itemCount: comments.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final comment = comments[index];
                return ListTile(
                  title: Text(
                    comment.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.email,
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 8),
                      Text(comment.body),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}