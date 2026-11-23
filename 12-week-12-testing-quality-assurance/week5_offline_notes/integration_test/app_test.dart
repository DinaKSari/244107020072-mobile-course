import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:week5_offline_notes/features/notes/presentation/pages/notes_page.dart';
import 'package:week5_offline_notes/features/notes/presentation/providers/notes_provider.dart';
import 'package:week5_offline_notes/features/settings/presentation/providers/settings_providers.dart';

import '../test/support/fake_repositories.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('pengguna membuat catatan dan melihatnya di daftar',
      (tester) async {
    final notesRepository = FakeNoteRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider.overrideWithValue(notesRepository),
          settingsRepositoryProvider
              .overrideWithValue(FakeSettingsRepository()),
        ],
        child: const MaterialApp(home: OfflineNotesPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Belum ada catatan.'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Judul'),
      'Catatan integrasi',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Isi'),
      'Alur lengkap',
    );
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Catatan integrasi'), findsOneWidget);
    expect(notesRepository.notes.single.body, 'Alur lengkap');
  });
}