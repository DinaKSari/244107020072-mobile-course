import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/core/failures.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:week5_offline_notes/features/notes/presentation/pages/notes_page.dart';
import 'package:week5_offline_notes/features/settings/domain/repositories/settings_repository.dart';
import 'package:week5_offline_notes/features/settings/presentation/providers/settings_providers.dart';
import 'package:week5_offline_notes/shared/providers.dart';

class _FakeNoteRepository implements NoteRepository {
  final _notes = [
    Note(
      id: 1,
      title: 'Rapat Mingguan',
      body: 'Agenda',
      updatedAt: DateTime(2026),
    ),
  ];

  @override
  Future<Result<List<Note>>> fetchNotes({String titleQuery = ''}) async => (
    data: _notes
        .where(
          (note) => note.title.toLowerCase().contains(titleQuery.toLowerCase()),
        )
        .toList(),
    failure: null,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<void> markOpenedNow() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('menampilkan empty state saat judul tidak ditemukan', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider.overrideWithValue(_FakeNoteRepository()),
          settingsRepositoryProvider.overrideWithValue(
            _FakeSettingsRepository(),
          ),
        ],
        child: const MaterialApp(home: OfflineNotesPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('notes-title-search')),
      'TidakAda',
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Tidak ada catatan dengan judul "TidakAda".'),
      findsOneWidget,
    );
  });
}
