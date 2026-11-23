import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/failures.dart';
import '../../../../shared/providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/note_title_validation.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_tile.dart';

class OfflineNotesPage extends ConsumerStatefulWidget {
  const OfflineNotesPage({super.key});

  @override
  ConsumerState<OfflineNotesPage> createState() => _OfflineNotesPageState();
}

class _OfflineNotesPageState extends ConsumerState<OfflineNotesPage> {
  @override
  void initState() {
    super.initState();
    ref.read(settingsRepositoryProvider).markOpenedNow();
  }

  void _toast(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _addNote() async {
    final input = await showDialog<({String title, String body})>(
      context: context,
      builder: (_) => const _AddNoteDialog(),
    );
    if (input == null) return;

    final r = await ref.read(noteRepositoryProvider).addNote(
          title: input.title,
          body: input.body,
        );
    ref.invalidate(notesProvider);
    if (r.failure != null) _toast(r.failure!.message);
  }

  Future<void> _syncData() async {
    if (ref.read(forceOfflineProvider)) {
      _toast('Masih mode offline, sync ditunda.');
      return;
    }
    final r = await ref.read(noteRepositoryProvider).markAllSynced();
    ref.invalidate(notesProvider);
    _toast(r.failure?.message ?? 'Sinkronisasi berhasil! (${r.data} catatan)');
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final dirtyCount = ref.watch(dirtyCountProvider);
    final forceOffline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          IconButton(
            icon: Icon(forceOffline ? Icons.wifi_off : Icons.wifi),
            tooltip: forceOffline ? 'Mode: Offline (paksa)' : 'Mode: Online',
            onPressed: () =>
                ref.read(forceOfflineProvider.notifier).state = !forceOffline,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(icon: const Icon(Icons.sync), onPressed: _syncData),
              if (dirtyCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text('$dirtyCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(notesProvider),
            child: Text('${e is Failure ? e.message : e}\nCoba lagi'),
          ),
        ),
        data: (list) => list.isEmpty
            ? const Center(child: Text('Belum ada catatan.'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final note = list[i];
                  return NoteTile(
                    note: note,
                    onTap: note.id == null
                        ? null
                        : () => context.push('/note/${note.id}'),
                    onLongPress: () async {
                      if (note.id == null) return;
                      await ref
                          .read(noteRepositoryProvider)
                          .deleteNote(note.id!);
                      ref.invalidate(notesProvider);
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddNoteDialog extends StatefulWidget {
  const _AddNoteDialog();

  @override
  State<_AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<_AddNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Catatan Baru'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: validateNoteTitle,
                textInputAction: TextInputAction.next,
              ),
              TextField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Isi'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              Navigator.pop(context, (
                title: _titleController.text.trim(),
                body: _bodyController.text.trim(),
              ));
            },
            child: const Text('Simpan'),
          ),
        ],
      );
}