import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class GetNotes {
  const GetNotes(this._repository);
  final NoteRepository _repository;

  Future<Result<List<Note>>> call({String titleQuery = ''}) =>
      _repository.fetchNotes(titleQuery: titleQuery);
}
