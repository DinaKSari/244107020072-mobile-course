import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/settings/presentation/providers/settings_providers.dart';
import 'router.dart';

final _lightTheme = ThemeData(
  colorSchemeSeed: Colors.indigo,
  useMaterial3: true,
);
final _darkTheme = ThemeData(
  colorSchemeSeed: Colors.indigo,
  brightness: Brightness.dark,
  useMaterial3: true,
);

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider).value ?? false;
    return MaterialApp.router(
      title: 'Week 4 - REST API',
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
