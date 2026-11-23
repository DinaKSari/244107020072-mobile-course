import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/features/notes/domain/note_title_validation.dart';

void main() {
  group('validateNoteTitle', () {
    test('menerima judul yang berisi teks', () {
      expect(validateNoteTitle('Belanja'), isNull);
    });

    test('menolak judul kosong atau hanya spasi', () {
      expect(validateNoteTitle(''), 'Judul wajib diisi.');
      expect(validateNoteTitle('   '), 'Judul wajib diisi.');
    });
  });
}