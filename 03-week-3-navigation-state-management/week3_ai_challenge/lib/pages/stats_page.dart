import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

// Menggunakan ConsumerWidget agar bisa menggunakan WidgetRef (ref)
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membaca dan berlangganan (watch) ke statsProvider.
    // Tipe data statsAsync adalah AsyncValue<List<String>>.
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Statistik'),
      ),
      // AsyncValue memiliki method .when() untuk menangani 3 kondisi wajib:
      body: statsAsync.when(
        // Kondisi 1: SUCCESS (data berhasil didapat)
        data: (stats) {
          // Menampilkan list data menggunakan ListView
          return ListView.builder(
            itemCount: stats.length, // Menyesuaikan dengan jumlah data (3 item)
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.analytics, color: Colors.blue),
                title: Text(stats[index]),
              );
            },
          );
        },
        // Kondisi 2: ERROR (terjadi exception)
        error: (error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Menampilkan pesan error
                Text(
                  'Terjadi Kesalahan:\n$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                // Tombol Retry
                ElevatedButton(
                  onPressed: () {
                    // ref.invalidate() akan MEMAKSA provider untuk mereset state-nya
                    // dan menjalankan ulang method build() di StatsNotifier dari awal.
                    ref.invalidate(statsProvider);
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        },
        // Kondisi 3: LOADING (menunggu future selesai)
        loading: () {
          // Menampilkan spinner di tengah layar
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}