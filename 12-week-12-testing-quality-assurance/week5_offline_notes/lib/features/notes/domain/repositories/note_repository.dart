import '../../../../core/failures.dart';
import '../entities/note.dart';

abstract class NoteRepository {
  Future<Result<List<Note>>> fetchNotes();
  Future<Result<Note?>> fetchNoteById(int id);
  Future<Result<Note>> addNote({required String title, String body = ''});
  Future<Failure?> updateNote(Note note); // null = sukses
  Future<Failure?> deleteNote(int id);
  Future<Result<int>> markAllSynced(); // jumlah catatan yang disinkronkan
}