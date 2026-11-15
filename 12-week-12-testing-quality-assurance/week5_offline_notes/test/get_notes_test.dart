import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/core/failures.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/features/notes/domain/usecases/get_note.dart';

import 'support/fake_repositories.dart';

void main() {
  test('GetNotes meneruskan daftar dari repository', () async {
    final repo = FakeNoteRepository(
      notes: [Note(title: 'A', updatedAt: DateTime(2026, 9, 27))]);
    final r = await GetNotes(repo).call();
    expect(r.failure, isNull);
    expect(r.data!.single.title, 'A');
  });

  test('GetNotes meneruskan failure tanpa melempar', () async {
    final r = await GetNotes(FakeNoteRepository(failFetch: true)).call();
    expect(r.failure, isA<LocalFailure>());
    expect(r.data, isNull);
  });
}