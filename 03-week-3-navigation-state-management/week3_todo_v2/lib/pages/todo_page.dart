import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(filteredTodosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar ToDo'),
        actions: [
          PopupMenuButton<TodoFilter>(
            initialValue: ref.watch(todoFilterProvider),
            onSelected: (filter) => ref.read(todoFilterProvider.notifier).setFilter(filter),
            itemBuilder: (context) => const [
              PopupMenuItem(value: TodoFilter.all, child: Text('Semua')),
              PopupMenuItem(value: TodoFilter.active, child: Text('Belum Selesai')),
              PopupMenuItem(value: TodoFilter.completed, child: Text('Selesai')),
            ],
          ),
        ],
      ),
      body: todosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (todos) {
          if (todos.isEmpty) return const Center(child: Text('Belum ada tugas'));
          
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) => TodoTile(todo: todos[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugas baru'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                ref.read(todoListProvider.notifier).add(text);
              }
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}