import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/chatInputSection.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';

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
      // Увеличил ширину до 0.85, чтобы таблицы и длинный текст влезали лучше
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.85,
      ),
      decoration: BoxDecoration(
        color: msg.isUser ? const Color(0xFF325732) : const Color(0xFF262626),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: msg.isUser ? const Radius.circular(18) : const Radius.circular(4),
          bottomRight: msg.isUser ? const Radius.circular(4) : const Radius.circular(18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Основной текст с поддержкой Markdown
          MarkdownBody(
            data: msg.text,
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(color: Colors.white, fontSize: 16),
              blockquote: const TextStyle(color: Colors.white70), // Цвет самого текста внутри цитаты
              blockquoteDecoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1), // Фон блока цитаты (делаем чуть светлее основного фона)
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(color: Color(0xFF5CB85C), width: 4), // Зеленая полоска слева как акцент
                ),
              ),
  blockquotePadding: const EdgeInsets.all(12),
              h1: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              h2: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              h3: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              em: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
              listBullet: const TextStyle(color: Colors.white),
              tableBody: const TextStyle(color: Colors.white),
              tableBorder: TableBorder.all(color: Colors.white24, width: 1),
              // Код внутри строки (backticks)
              code: TextStyle(
                backgroundColor: Colors.black26,
                color: Colors.greenAccent[100],
                fontFamily: 'monospace',
              ),
            ),
          ),

          // Кнопка копирования (только для сообщений модели)
          if (!msg.isUser) ...[
            const Divider(color: Colors.white10, height: 20),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: msg.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Текст скопирован"),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.white,
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(Icons.copy_rounded, color: Colors.white54, size: 16),
                  SizedBox(width: 4),
                  Text(
                    "Копировать",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
}