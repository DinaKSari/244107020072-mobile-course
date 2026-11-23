import 'package:week5_offline_notes/core/failures.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:week5_offline_notes/features/settings/domain/repositories/settings_repository.dart';

class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({
    List<Note> notes = const [],
    this.failAdd = false,
    this.failFetch = false,
  })
      : notes = List.of(notes);

  final List<Note> notes;
  bool failAdd;
  final bool failFetch;
  int _nextId = 1;

  @override
    Future<Result<List<Note>>> fetchNotes() async => failFetch
      ? (data: null, failure: const LocalFailure('db locked (simulasi)'))
      : (data: List<Note>.unmodifiable(notes), failure: null);

  @override
  Future<Result<Note?>> fetchNoteById(int id) async => (
        data: notes.where((note) => note.id == id).firstOrNull,
        failure: null,
      );

  @override
  Future<Result<Note>> addNote({required String title, String body = ''}) async {
    if (failAdd) {
      return (
        data: null,
        failure: const LocalFailure('Gagal menyimpan catatan.'),
      );
    }
    final note = Note(
      id: _nextId++,
      title: title,
      body: body,
      updatedAt: DateTime(2026, 11, 15),
      dirty: true,
    );
    notes.add(note);
    return (data: note, failure: null);
  }

  @override
  Future<Failure?> updateNote(Note note) async {
    final index = notes.indexWhere((item) => item.id == note.id);
    if (index >= 0) notes[index] = note;
    return null;
  }

  @override
  Future<Failure?> deleteNote(int id) async {
    notes.removeWhere((note) => note.id == id);
    return null;
  }

  @override
  Future<Result<int>> markAllSynced() async => (data: 0, failure: null);
}

class FakeSettingsRepository implements SettingsRepository {
  @override
  Future<bool> getDarkMode() async => false;

  @override
  Future<String?> getLastOpened() async => null;

  @override
  Future<void> markOpenedNow() async {}

  @override
  Future<void> setDarkMode(bool value) async {}
}