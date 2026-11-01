import 'package:flutter/material.dart';

import '../ai/ai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _aiService = AiService();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text: 'Halo! Aku siap membantu membuat catatanmu lebih jelas, rapi, dan mudah dibaca. Ceritakan ide yang ingin kamu tulis atau pilih salah satu saran di bawah.',
      fromUser: false,
    ),
  ];
  bool _isSending = false;

  static const _suggestions = [
    'Bantu rapikan catatan rapat',
    'Buat ide ini lebih terstruktur',
    'Bantu tulis jurnal harian',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? suggestion]) async {
    final message = (suggestion ?? _messageController.text).trim();
    if (message.isEmpty || _isSending) return;

    _messageController.clear();
    setState(() {
      _messages.add(_ChatMessage(text: message, fromUser: true));
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final response = await _aiService.ask(
        'Kamu adalah asisten penulisan untuk aplikasi catatan. Bantu pengguna '
        'menyusun, memperjelas, dan memperbaiki catatan tanpa mengubah maksudnya. '
        'Gunakan bahasa Indonesia yang natural, format yang mudah dibaca, dan '
        'berikan contoh revisi jika bermanfaat. Jawab langsung dan ringkas.\n\n'
        'Permintaan pengguna: $message',
      );
      if (!mounted) return;
      setState(
        () => _messages.add(_ChatMessage(text: response, fromUser: false)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          const _ChatMessage(
            text: 'Maaf, aku belum bisa menjawab. Periksa koneksi internet dan pastikan API key Gemini sudah disimpan di Pengaturan, lalu coba lagi.',
            fromUser: false,
            isError: true,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: colors.primaryContainer,
              child: Icon(Icons.auto_awesome, color: colors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Asisten Catatan', style: TextStyle(fontSize: 17)),
                Text(
                  'Teman menulis berbasis AI',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              itemCount: _messages.length + (_isSending ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isSending && index == _messages.length) {
                  return const _TypingIndicator();
                }
                return _MessageBubble(message: _messages[index]);
              },
            ),
          ),
          if (_messages.length == 1 && !_isSending)
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _suggestions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) => ActionChip(
                  avatar: const Icon(Icons.lightbulb_outline, size: 17),
                  label: Text(_suggestions[index]),
                  onPressed: () => _sendMessage(_suggestions[index]),
                ),
              ),
            ),
          _MessageComposer(
            controller: _messageController,
            isSending: _isSending,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.fromUser,
    this.isError = false,
  });

  final String text;
  final bool fromUser;
  final bool isError;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bubbleColor = message.fromUser
        ? colors.primary
        : message.isError
        ? colors.errorContainer
        : colors.surfaceContainerHigh;
    final textColor = message.fromUser
        ? colors.onPrimary
        : message.isError
        ? colors.onErrorContainer
        : colors.onSurface;

    return Align(
      alignment: message.fromUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(message.fromUser ? 18 : 5),
            bottomRight: Radius.circular(message.fromUser ? 5 : 18),
          ),
        ),
        child: SelectableText(
          message.text,
          style: TextStyle(color: textColor, height: 1.4),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(18),
        ),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                key: const Key('chat-message-input'),
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Tulis ide atau catatanmu...',
                  filled: true,
                  fillColor: colors.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(26),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              key: const Key('chat-send-button'),
              tooltip: 'Kirim pesan',
              onPressed: isSending ? null : onSend,
              icon: const Icon(Icons.arrow_upward_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
