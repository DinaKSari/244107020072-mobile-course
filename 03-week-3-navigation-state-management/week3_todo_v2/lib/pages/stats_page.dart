import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(todoStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik Tugas')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (stats) => ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ListTile(
              title: const Text('Total Tugas'),
              trailing: Text('${stats.$1}', style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              title: const Text('Belum Selesai'),
              trailing: Text('${stats.$2}', style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              title: const Text('Selesai'),
              trailing: Text('${stats.$3}', style: Theme.of(context).textTheme.titleLarge),
            ),
          ],
        ),
      ),
    );
  }
}