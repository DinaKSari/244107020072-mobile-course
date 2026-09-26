import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/note.dart';
import '../data/providers.dart';

class NoteDetailPage extends ConsumerStatefulWidget {
  const NoteDetailPage({super.key, required this.noteId});

  final int noteId;

  @override
  ConsumerState<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends ConsumerState<NoteDetailPage> {
  Note? _note;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Selalu baca dari repository lokal (SQLite), bukan dari state
  // halaman list, agar tetap benar walau dibuka langsung lewat URL.
  Future<void> _load() async {
    final note =
        await ref.read(noteRepositoryProvider).fetchNoteById(widget.noteId);
    setState(() {
      _note = note;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _note == null
              ? const Center(child: Text('Catatan tidak ditemukan.'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_note!.title,
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(_note!.body),
                      const SizedBox(height: 16),
                      if (_note!.dirty)
                        const Chip(label: Text('Belum tersinkron')),
                      const SizedBox(height: 8),
                      Text(
                          'Terakhir diubah: ${_note!.updatedAt.toLocal()}'),
                    ],
                  ),
                ),
    );
  }
}