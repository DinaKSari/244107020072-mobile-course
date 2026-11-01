import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';

import 'api_client.dart';
import '../features/notes/data/repositories/note_repository_impl.dart';
import '../features/notes/domain/repositories/note_repository.dart';
import 'db.dart';

final dioProvider = Provider<Dio>((ref) => createDio());
final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepositoryImpl(openDb: openNotesDb),
);

// true = jangan hit network, hanya baca cache lokal.
final forceOfflineProvider = StateProvider<bool>((ref) => false);
