import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_todo_v2/main.dart'; // Sesuaikan nama paket projek Anda

void main() {
  testWidgets('menambah tugas baru', (tester) async {
    // 1. Bungkus aplikasi dengan ProviderScope
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    
    // 2. Gunakan pumpAndSettle untuk menunggu proses async awal selesai dimuat
    await tester.pumpAndSettle();
    
    // 3. Verifikasi teks kosong awal tampil
    expect(find.text('Belum ada tugas'), findsOneWidget);

    // 4. Tap tombol tambah tugas (Icon add)
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // 5. Masukkan teks ke dalam TextField dialog
    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');
    
    // 6. Tap tombol Tambah di dialog
    await tester.tap(find.text('Tambah'));
    
    // 7. Gunakan pumpAndSettle agar widget mendengarkan data AsyncValue yang baru diperbarui
    await tester.pumpAndSettle();

    // 8. Verifikasi tugas berhasil masuk ke daftar UI
    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });
}