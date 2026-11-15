import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/features/notes/presentation/pages/notes_page.dart';
import 'package:week5_offline_notes/features/notes/presentation/providers/notes_provider.dart';
import 'package:week5_offline_notes/features/settings/presentation/providers/settings_providers.dart';

import 'support/fake_repositories.dart';

Widget createNotesPage(FakeNoteRepository notesRepository) => ProviderScope(
      overrides: [
        noteRepositoryProvider.overrideWithValue(notesRepository),
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      ],
      child: const MaterialApp(home: OfflineNotesPage()),
    );

void main() {
  testWidgets('menampilkan keadaan awal tanpa catatan', (tester) async {
    await tester.pumpWidget(createNotesPage(FakeNoteRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada catatan.'), findsOneWidget);
  });

  testWidgets('menolak judul kosong lalu menyimpan catatan valid',
      (tester) async {
    final repository = FakeNoteRepository();
    await tester.pumpWidget(createNotesPage(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Judul wajib diisi.'), findsOneWidget);
    expect(repository.notes, isEmpty);

    await tester.enterText(find.widgetWithText(TextFormField, 'Judul'), 'Rencana');
    await tester.enterText(find.widgetWithText(TextField, 'Isi'), 'Belajar Flutter');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Rencana'), findsOneWidget);
    expect(repository.notes.single.body, 'Belajar Flutter');
  });

  testWidgets('menampilkan pesan jika repository gagal menyimpan',
      (tester) async {
    final repository = FakeNoteRepository(failAdd: true);
    await tester.pumpWidget(createNotesPage(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Judul'), 'Catatan');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Gagal menyimpan catatan.'), findsOneWidget);
    expect(repository.notes, isEmpty);
  });
}