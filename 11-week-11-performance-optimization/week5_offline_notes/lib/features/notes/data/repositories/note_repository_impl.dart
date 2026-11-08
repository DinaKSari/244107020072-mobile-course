import 'package:sqflite/sqflite.dart';
import '../../../../core/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  const NoteRepositoryImpl({required this.openDb});

  final Future<Database> Function() openDb;

  Future<Result<T>> _run<T>(
      String errorMessage, Future<T> Function(Database db) op) async {
    try {
      return (data: await op(await openDb()), failure: null);
    } catch (_) {
      return (data: null, failure: LocalFailure(errorMessage));
    }
  }

  @override
  Future<Result<List<Note>>> fetchNotes() =>
      _run('Gagal membaca catatan.', (db) async {
        final rows = await db.query('notes', orderBy: 'updated_at DESC');
        return rows.map((r) => NoteModel.fromMap(r).toEntity()).toList();
      });

  @override
  Future<Result<Note?>> fetchNoteById(int id) =>
      _run<Note?>('Gagal membaca catatan.', (db) async {
        final rows = await db.query('notes',
            where: 'id = ?', whereArgs: [id], limit: 1);
        return rows.isEmpty ? null : NoteModel.fromMap(rows.first).toEntity();
      });

  @override
  Future<Result<Note>> addNote({required String title, String body = ''}) =>
      _run('Gagal menyimpan catatan.', (db) async {
        final now = DateTime.now();
        final model =
            NoteModel(title: title, body: body, updatedAt: now, dirty: true);
        final id = await db.insert('notes', model.toMap());
        return Note(id: id, title: title, body: body, updatedAt: now, dirty: true);
      });

  // Edit otomatis menandai dirty agar ikut sync.
  @override
  Future<Failure?> updateNote(Note note) async {
    final r = await _run(
      'Gagal memperbarui catatan.',
      (db) => db.update(
        'notes',
        NoteModel(
                id: note.id,
                title: note.title,
                body: note.body,
                updatedAt: DateTime.now(),
                dirty: true)
            .toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      ),
    );
    return r.failure;
  }

  @override
  Future<Failure?> deleteNote(int id) async {
    final r = await _run('Gagal menghapus catatan.',
        (db) => db.delete('notes', where: 'id = ?', whereArgs: [id]));
    return r.failure;
  }

  @override
  Future<Result<int>> markAllSynced() =>
      _run('Gagal sinkronisasi.', (db) async {
        await Future.delayed(const Duration(seconds: 1)); // simulasi upload
        return db.update('notes', {'dirty': 0}, where: 'dirty = 1');
      });
}