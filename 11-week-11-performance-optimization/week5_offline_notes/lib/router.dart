import 'package:go_router/go_router.dart';
import 'features/notes/presentation/pages/note_detail_page.dart';
import 'features/notes/presentation/pages/notes_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (c, s) => const OfflineNotesPage()),
    GoRoute(
      path: '/note/:id',
      builder: (c, s) => NoteDetailPage(
          noteId: int.tryParse(s.pathParameters['id'] ?? '') ?? 0),
    ),
    GoRoute(path: '/settings', builder: (c, s) => const SettingsPage()),
  ],
);