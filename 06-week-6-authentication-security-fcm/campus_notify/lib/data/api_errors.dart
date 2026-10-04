import 'package:dio/dio.dart';

/// Exception mentah -> pesan ramah pengguna.
String friendlyError(Object e) {
  if (e is! DioException) return e.toString().replaceFirst('Exception: ', '');
  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout =>
      'Koneksi timeout, coba lagi.',
    DioExceptionType.connectionError => 'Tidak ada koneksi internet.',
    _ => switch (e.response?.statusCode) {
        401 => 'Sesi berakhir, silakan login ulang.',
        403 => 'Anda tidak punya akses.',
        404 => 'Data tidak ditemukan.',
        final statusCode? when statusCode >= 500 =>
          'Server bermasalah, coba beberapa saat lagi.',
        _ => 'Terjadi kesalahan.',
      },
  };
}