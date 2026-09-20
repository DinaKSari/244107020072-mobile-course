import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/comment_page.dart';

void main() {
  // ProviderScope wajib ditambahkan di akar aplikasi untuk menggunakan Riverpod
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riverpod API Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Mengarahkan langsung ke halaman komentar dengan contoh postId = 1
      home: const CommentPage(postId: 1),
    );
  }
}