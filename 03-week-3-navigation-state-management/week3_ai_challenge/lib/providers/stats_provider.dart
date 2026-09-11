import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// AsyncNotifier digunakan karena kita berurusan dengan data Future (asynchronous).
// List<String> adalah tipe data state kita (berisi 3 item statistik).
class StatsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    // 1. Simulasi proses loading/pengambilan data dari internet (delay 2 detik)
    await Future.delayed(const Duration(seconds: 2));

    // 2. Simulasi kemungkinan gagal (30% error rate)
    // Random().nextDouble() menghasilkan angka 0.0 hingga 1.0. 
    // Jika di bawah 0.3, kita lempar exception.
    final isError = Random().nextDouble() < 0.3;
    if (isError) {
      // Saat exception dilempar, Riverpod otomatis mengubah state menjadi AsyncError
      throw Exception('Gagal mengambil data statistik dari server.');
    }

    // 3. Jika lolos dari error (70% kemungkinan), kembalikan data sukses.
    // Riverpod akan mengubah state menjadi AsyncData dan mengirimkan list ini ke UI.
    return [
      'Total Pengguna: 1,500',
      'Pendapatan: Rp 15.000.000',
      'Rating Aplikasi: 4.8 / 5.0'
    ];
  }
}

// Mendaftarkan Notifier ke dalam Provider global agar bisa dibaca oleh UI (ConsumerWidget)
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<String>>(() {
  return StatsNotifier();
});