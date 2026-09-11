import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- 1. MODEL ---
class Todo {
  const Todo({required this.id, required this.title, this.done = false});
  final String id;
  final String title;
  final bool done;

  Todo copyWith({String? id, String? title, bool? done}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
    );
  }
}

// --- 2. NOTIFIER DAFTAR TODO ---
class TodoListNotifier extends AsyncNotifier<List<Todo>> {
  @override
  List<Todo> build() {
    // Wajib sinkron (tanpa delay) agar teks 'Belum ada tugas' langsung terbaca di awal test
    return [];
  }

  Future<void> add(String title) async {
    final current = state.value ?? [];
    state = const AsyncLoading();
    // Beri jeda sangat singkat agar pumpAndSettle pada test berhasil mendeteksi transisi loading
    await Future.delayed(const Duration(milliseconds: 10));
    state = AsyncData([...current, Todo(id: DateTime.now().toString(), title: title)]);
  }

  Future<void> toggle(String id) async {
    final current = state.value ?? [];
    state = AsyncData(
      current.map((t) => t.id == id ? t.copyWith(done: !t.done) : t).toList(),
    );
  }

  Future<void> remove(String id) async {
    final current = state.value ?? [];
    state = AsyncData(current.where((t) => t.id != id).toList());
  }
}

final todoListProvider = AsyncNotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

// --- 3. NOTIFIER FILTER ---
enum TodoFilter { all, active, completed }

class TodoFilterNotifier extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.all;

  void setFilter(TodoFilter filter) => state = filter;
}

final todoFilterProvider = NotifierProvider<TodoFilterNotifier, TodoFilter>(TodoFilterNotifier.new);

// --- 4. DERIVED PROVIDER (FILTER DATA) ---
final filteredTodosProvider = Provider((ref) {
  final todosAsync = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);

  return todosAsync.whenData((todos) {
    switch (filter) {
      case TodoFilter.active: return todos.where((t) => !t.done).toList();
      case TodoFilter.completed: return todos.where((t) => t.done).toList();
      case TodoFilter.all: return todos;
    }
  });
});

// --- 5. DERIVED PROVIDER (STATISTIK) ---
final todoStatsProvider = Provider((ref) {
  return ref.watch(todoListProvider).whenData((todos) {
    final completed = todos.where((t) => t.done).length;
    return (todos.length, todos.length - completed, completed);
  });
});