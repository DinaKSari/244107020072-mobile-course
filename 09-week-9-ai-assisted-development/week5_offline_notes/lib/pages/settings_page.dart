import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeState = ref.watch(darkModeProvider);
    final lastOpened = ref.watch(lastOpenedProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: darkModeState.when(
        data: (isDarkMode) => ListView(
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: isDarkMode,
              onChanged: (value) =>
                  ref.read(darkModeProvider.notifier).toggle(),
            ),
            ListTile(
              title: const Text('Terakhir dibuka'),
              subtitle: Text(lastOpened ?? '-'),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}