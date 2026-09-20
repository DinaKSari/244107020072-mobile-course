import 'package:go_router/go_router.dart';
import 'pages/post_list_page.dart';
import 'pages/post_detail_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/', // Atau '/paged'
      builder: (context, state) => const PostListPage(), 
    ),
    GoRoute(
      path: '/post/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return PostDetailPage(id: id);
      },
    ),
  ],
);