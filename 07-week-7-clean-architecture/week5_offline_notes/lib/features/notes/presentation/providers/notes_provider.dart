import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/failures.dart';
import '../../../../shared/db.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/get_note.dart';

final noteRepositoryProvider = Provider<NoteRepository>(
    (ref) => NoteRepositoryImpl(openDb: openNotesDb));

final getNotesProvider =
    Provider((ref) => GetNotes(ref.watch(noteRepositoryProvider)));

final notesProvider = FutureProvider<List<Note>>(
  (ref) async => (await ref.watch(getNotesProvider).call()).orThrow,
  retry: (retryCount, error) => null,
);

final dirtyCountProvider = Provider<int>((ref) =>
    ref.watch(notesProvider).value?.where((n) => n.dirty).length ?? 0);

final noteByIdProvider = FutureProvider.family<Note?, int>((ref, id) async =>
    (await ref.watch(noteRepositoryProvider).fetchNoteById(id)).orThrow);