import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures.dart';
import '../../../../shared/providers.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/get_note.dart';

final getNotesProvider = Provider(
  (ref) => GetNotes(ref.watch(noteRepositoryProvider)),
);

final notesProvider = FutureProvider.family<List<Note>, String>(
  (ref, titleQuery) async =>
      (await ref.watch(getNotesProvider).call(titleQuery: titleQuery)).orThrow,
  retry: (retryCount, error) => null,
);

final dirtyCountProvider = Provider<int>(
  (ref) =>
      ref.watch(notesProvider('')).value?.where((n) => n.dirty).length ?? 0,
);

final noteByIdProvider = FutureProvider.family<Note?, int>(
  (ref, id) async =>
      (await ref.watch(noteRepositoryProvider).fetchNoteById(id)).orThrow,
);
