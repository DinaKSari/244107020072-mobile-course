import 'package:dio/dio.dart';
import 'comment_model.dart';

// Fungsi untuk menerjemahkan DioException menjadi pesan yang ramah pengguna
String getFriendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Koneksi terputus karena terlalu lama (Timeout 10 detik).';
      case DioExceptionType.connectionError:
        return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) return 'Data komentar tidak ditemukan (404).';
        if (statusCode == 500) return 'Terjadi kesalahan pada server (500).';
        return 'Terjadi kesalahan HTTP: $statusCode';
      default:
        return 'Terjadi kesalahan jaringan yang tidak terduga.';
    }
  }
  return 'Terjadi kesalahan sistem: $error';
}

class CommentRepository {
  final Dio _dio;

  CommentRepository(this._dio);

  // Method untuk mengambil komentar berdasarkan postId
  Future<List<Comment>> fetchComments(int postId) async {
    try {
      // Mengirim request GET ke /comments dengan query param ?postId={id}
      final response = await _dio.get(
        '/comments',
        queryParameters: {'postId': postId},
      );
      
      // Melakukan parsing dari List dinamis ke List<Comment>
      final List<dynamic> data = response.data;
      return data.map((json) => Comment.fromJson(json)).toList();
    } catch (e) {
      // Melempar (throw) pesan error ramah pengguna agar ditangkap oleh Riverpod
      throw getFriendlyErrorMessage(e);
    }
  }
}