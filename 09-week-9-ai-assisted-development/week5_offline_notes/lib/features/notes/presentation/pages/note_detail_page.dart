import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures.dart';
import '../../../../core/format.dart';
import '../../../../shared/providers.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_provider.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.noteId});
  final int noteId;

  Future<void> _edit(BuildContext context, WidgetRef ref, Note note) async {
    final titleCtrl = TextEditingController(text: note.title);
    final bodyCtrl = TextEditingController(text: note.body);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Catatan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: bodyCtrl,
              decoration: const InputDecoration(labelText: 'Isi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (saved != true) return;
    await ref
        .read(noteRepositoryProvider)
        .updateNote(
          Note(
            id: note.id,
            title: titleCtrl.text,
            body: bodyCtrl.text,
            updatedAt: note.updatedAt,
          ),
        );
    ref.invalidate(notesProvider);
    ref.invalidate(noteByIdProvider(noteId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(noteByIdProvider(noteId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          if (note.value != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _edit(context, ref, note.value!),
            ),
        ],
      ),
      body: note.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${e is Failure ? e.message : e}')),
        data: (n) => n == null
            ? const Center(child: Text('Catatan tidak ditemukan.'))
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(n.body),
                    const SizedBox(height: 16),
                    if (n.dirty) const Chip(label: Text('Belum tersinkron')),
                    const SizedBox(height: 8),
                    Text('Terakhir diubah: ${formatTimestamp(n.updatedAt)}'),
                  ],
                ),
              ),
      ),
    );
  }
}
