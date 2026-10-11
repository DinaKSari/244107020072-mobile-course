# praktikum 1
## petakan file ke layer
1. data/local/note.dart	data | entity dan model tercampur | (toMap/fromMap di entity)
2. data/repositories/note_repository.dart | data | tidak ada interface, langsung memakai sqflite
3. data/sync.dart | data | logika bisnis tercampur dengan SQL dan jsonDecode
4.  data/providers.dart | presentation | satu file berisi DI, notifier, helper test, dan DioException
5. data/prefs.dart	data | tidak | ada kontrak (interface)
6. pages/notes_page.dart | presentation | setState manual dan memanggil sync.dart langsung
7. pages/note_detail_page.dart | presentation | setState manual untuk load data
# praktikum 2
# praktikum 3
# tugas ai challenge
# refactoring 
# tugas akhir week 7