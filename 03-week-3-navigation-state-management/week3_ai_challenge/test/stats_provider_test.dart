import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Asumsikan path file provider-mu ada di sini
import 'package:week3_ai_challenge/providers/stats_provider.dart'; 

void main() {
  test('statsProvider memiliki state awal AsyncLoading', () {
    // 1. Buat ProviderContainer untuk menampung state saat proses testing
    final container = ProviderContainer();
    
    // 2. Bersihkan container setelah test selesai untuk mencegah memory leak
    addTearDown(container.dispose);

    // 3. Baca provider secara synchronous sebelum delay Future-nya selesai
    final state = container.read(statsProvider);

    // 4. Lakukan pengecekan: 
    // State harus berupa AsyncLoading pada detik pertama.
    expect(state is AsyncLoading, true);
  });

  test('statsProvider memanggil ulang build() saat di-invalidate', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Baca state awal (memicu method build() berjalan)
    final initialState = container.read(statsProvider);
    expect(initialState is AsyncLoading, true);

    // Simulasikan action invalidate (mirip ketika tombol "Coba Lagi" ditekan)
    container.invalidate(statsProvider);

    // Setelah di-invalidate, statusnya harus reset menjadi AsyncLoading lagi
    final newState = container.read(statsProvider);
    expect(newState is AsyncLoading, true);
  });
}