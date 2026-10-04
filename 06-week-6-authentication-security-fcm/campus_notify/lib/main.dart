import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  registerBackgroundHandler();
  await requestNotificationPermission();
  await initLocalNotifications();

  final container = ProviderContainer();
  // Token baru / refresh: kirim ke backend bila sudah login.
  await initFcmToken(onToken: () async {
    if (container.read(authStateProvider).value == true) {
      await registerDevice(container.read(dioProvider));
    }
  });

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.onDispose(refresh.dispose);
  String? pending; // rute notifikasi yang masuk sebelum login

  final router = GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      if (auth.isLoading) return null;
      final loggedIn = auth.value ?? false;
      final goingLogin = state.matchedLocation == Routes.login;
      if (!loggedIn && !goingLogin) return Routes.login;
      if (loggedIn && goingLogin) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: Routes.home, builder: (_, _) => const HomePage()),
      GoRoute(
        path: Routes.announcement,
        builder: (_, s) => AnnouncementPage(id: s.pathParameters['id'] ?? ''),
      ),
    ],
  );

  bool isLoggedIn() => ref.read(authStateProvider).value == true;

  void onLoggedIn() {
    registerDevice(ref.read(dioProvider));
    if (pending != null) {
      router.go(pending!);
      pending = null;
    }
  }

  ref.listen(authStateProvider, (prev, next) {
    refresh.value++;
    if (next.value == true && prev?.value != true) onLoggedIn();
  });

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (isLoggedIn()) onLoggedIn();
    setupMessageHandlers((route) {
      if (isLoggedIn()) {
        router.go(route);
      } else {
        pending = route;
      }
    });
  });

  return router;
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'Campus Notify',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: ref.watch(routerProvider),
      );
}