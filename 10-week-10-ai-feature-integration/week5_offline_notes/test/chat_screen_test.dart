import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/features/chat_screen.dart';

void main() {
  testWidgets('menampilkan sapaan, saran, dan kolom pesan', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChatScreen()));

    expect(find.text('Asisten Catatan'), findsOneWidget);
    expect(find.textContaining('Halo! Aku siap membantu'), findsOneWidget);
    expect(find.text('Bantu rapikan catatan rapat'), findsOneWidget);
    expect(find.byKey(const Key('chat-message-input')), findsOneWidget);
    expect(find.byKey(const Key('chat-send-button')), findsOneWidget);
  });
}
