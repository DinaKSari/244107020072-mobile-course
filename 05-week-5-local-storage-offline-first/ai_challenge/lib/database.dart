import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

// File ini akan di-generate oleh build_runner
part 'database.g.dart';

// Tabel Catatan
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // READ: Reactive stream (UI otomatis update)
  Stream<List<Note>> watchAllNotes() => select(notes).watch();
  
  // CREATE
  Future<int> addNote(NotesCompanion entry) => into(notes).insert(entry);
  
  // UPDATE
  Future<bool> updateNote(Note entry) => update(notes).replace(entry);
  
  // DELETE
  Future<int> deleteNote(Note entry) => delete(notes).delete(entry);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'notes.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}