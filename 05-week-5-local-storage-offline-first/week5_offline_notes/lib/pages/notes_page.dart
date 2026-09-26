import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';
import '../data/providers.dart';

final noteRepositoryProvider = Provider((ref) => NoteRepository());

class OfflineNotesPage extends ConsumerStatefulWidget {
  const OfflineNotesPage({super.key});

  @override
  ConsumerState<OfflineNotesPage> createState() => _OfflineNotesPageState();
}

class _OfflineNotesPageState extends ConsumerState<OfflineNotesPage> {
  List<Note> _notes = [];
  int _dirtyCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Mengambil data catatan dan jumlah antrean sync dari SQLite
  // (selalu lokal, jadi akurat walau tidak ada koneksi sama sekali)
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final repository = ref.read(noteRepositoryProvider);
    final notes = await repository.fetchNotes();
    final dirtyCount = await repository.countDirty();

    setState(() {
      _notes = notes;
      _dirtyCount = dirtyCount;
      _isLoading = false;
    });
  }

  Future<void> _addNote() async {
    await ref.read(noteRepositoryProvider).addNote(
          title: 'Catatan Baru',
          body: 'Dibuat pada ${DateTime.now().toLocal()}',
        );
    _loadData();
  }

  Future<void> _syncData() async {
    if (ref.read(forceOfflineProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masih mode offline, sync ditunda.')),
      );
      return;
    }
    final synced = await ref.read(noteRepositoryProvider).syncNotes();
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sinkronisasi berhasil! ($synced catatan)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final forceOffline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          // Toggle simulasi offline deterministik (bagian 3)
          IconButton(
            icon: Icon(forceOffline ? Icons.wifi_off : Icons.wifi),
            tooltip: forceOffline ? 'Mode: Offline (paksa)' : 'Mode: Online',
            onPressed: () =>
                ref.read(forceOfflineProvider.notifier).state = !forceOffline,
          ),
          // Indikator Badge untuk catatan yang 'dirty'
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.sync),
                onPressed: _syncData,
              ),
              if (_dirtyCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_dirtyCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? const Center(child: Text('Belum ada catatan.'))
              : ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return ListTile(
                      title: Text(note.title),
                      subtitle: Text(note.body),
                      trailing: note.dirty
                          ? const Icon(Icons.cloud_off, color: Colors.orange)
                          : const Icon(Icons.cloud_done, color: Colors.green),
                      onLongPress: () async {
                        if (note.id != null) {
                          await ref
                              .read(noteRepositoryProvider)
                              .deleteNote(note.id!);
                          _loadData();
                        }
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}