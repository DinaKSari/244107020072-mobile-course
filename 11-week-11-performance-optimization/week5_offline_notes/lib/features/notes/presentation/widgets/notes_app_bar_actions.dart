import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers.dart';
import '../providers/notes_provider.dart';

class OfflineModeButton extends ConsumerWidget {
  const OfflineModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(
      forceOfflineProvider.select((offline) => offline),
    );

    return IconButton(
      icon: Icon(isOffline ? Icons.wifi_off : Icons.wifi),
      tooltip: isOffline ? 'Mode: Offline (paksa)' : 'Mode: Online',
      onPressed: () =>
          ref.read(forceOfflineProvider.notifier).state = !isOffline,
    );
  }
}

class SyncStatusButton extends ConsumerWidget {
  const SyncStatusButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dirtyCount = ref.watch(
      notesProvider.select(
        (notes) => notes.value?.where((note) => note.dirty).length ?? 0,
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.sync),
          onPressed: () => _sync(context, ref),
        ),
        if (dirtyCount > 0)
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
                '$dirtyCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    if (ref.read(forceOfflineProvider)) {
      _showMessage(context, 'Masih mode offline, sync ditunda.');
      return;
    }

    final result = await ref.read(noteRepositoryProvider).markAllSynced();
    ref.invalidate(notesProvider);
    if (context.mounted) {
      _showMessage(
        context,
        result.failure?.message ??
            'Sinkronisasi berhasil! (${result.data} catatan)',
      );
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
