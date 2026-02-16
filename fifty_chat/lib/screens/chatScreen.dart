import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/chatInputSection.dart';

// Модель сообщения
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  final int chatId;           // ID для памяти
  final String initialUserText;
  final String initialAiText;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.initialUserText,
    required this.initialAiText,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Сразу добавляем первые сообщения, которые пришли с главного экрана
    _messages.add(ChatMessage(text: widget.initialUserText, isUser: true));
    _messages.add(ChatMessage(text: widget.initialAiText, isUser: false));
  }

  // Функция для ПОСЛЕДУЮЩИХ сообщений
  Future<void> _sendMessage(String text) async {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://104.164.62.133:3000/chats/anonymous'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "content": text,
          "model": "x-ai/grok-4.1-fast",
          "chat_id": widget.chatId // <--- ВОТ ОНА, ПАМЯТЬ! Отправляем ID.
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final aiText = data['ai_response']['content'];

        setState(() {
          _messages.add(ChatMessage(text: aiText, isUser: false));
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: "Ошибка соединения :(", isUser: false));
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white), // Стрелка назад
        title: const Text("Чат с FiftyChat", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildBubble(_messages[index]);
              },
            ),
          ),
          if (_isLoading)
             const Padding(
               padding: EdgeInsets.only(bottom: 10),
               child: LinearProgressIndicator(color: Colors.green, backgroundColor: Colors.transparent),
             ),
          ChatInputSection(onSendPressed: _sendMessage),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isUser ? const Color(0xFF325732) : const Color(0xFF262626),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: msg.isUser ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight: msg.isUser ? const Radius.circular(4) : const Radius.circular(18),
          ),
        ),
        child: SelectableText(msg.text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}