import '../providers/settings_providers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ai/ai_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _configureAiKey(BuildContext context) async {
    final controller = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Atur API key Gemini'),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'API key',
            hintText: 'Tempel API key Gemini di sini',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim().isNotEmpty),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (saved == true) {
      await AiService().saveApiKey(controller.text.trim());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API key Gemini berhasil disimpan.')),
        );
      }
    }
    controller.dispose();
  }

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
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('API key Gemini'),
              subtitle: const Text('Disimpan secara aman di perangkat'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _configureAiKey(context),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
