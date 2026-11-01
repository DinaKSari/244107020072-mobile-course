import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/core/failures.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:week5_offline_notes/features/notes/domain/usecases/get_note.dart';

class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({this.items = const [], this.fail = false});
  final List<Note> items;
  final bool fail;

  @override
  Future<Result<List<Note>>> fetchNotes({String titleQuery = ''}) async => fail
      ? (data: null, failure: const LocalFailure('db locked (simulasi)'))
      : (data: items, failure: null);

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  test('GetNotes meneruskan daftar dari repository', () async {
    final repo = FakeNoteRepository(
      items: [Note(title: 'A', updatedAt: DateTime(2026, 9, 27))],
    );
    final r = await GetNotes(repo).call();
    expect(r.failure, isNull);
    expect(r.data!.single.title, 'A');
  });

  test('GetNotes meneruskan failure tanpa melempar', () async {
    final r = await GetNotes(FakeNoteRepository(fail: true)).call();
    expect(r.failure, isA<LocalFailure>());
    expect(r.data, isNull);
  });
}
