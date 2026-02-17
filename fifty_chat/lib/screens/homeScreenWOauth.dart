import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/loginButton.dart';
import '../widgets/chatInputSection.dart'; // Проверь имя файла (n вместо m)
import 'chatScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  // Твоя новая логика отправки первого сообщения
  Future<void> _handleInitialMessage(String text) async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://104.164.62.133:3000/chats/anonymous'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "content": text,
          "model": "x-ai/grok-4.1-fast"
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        
        final int chatId = data['chat_id'];
        final String aiResponse = data['ai_response']['content'];

        if (!mounted) return;

        // Переходим на экран чата
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
              initialUserText: text,
              initialAiText: aiResponse,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Ошибка: $e')),
  );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          LoginButton(),
          SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const Spacer(flex: 3), // Пружина сверху (как в твоем коде)

              // Центрированный текст "Привет, я FiftyChat"
              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Привет, я ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const TextSpan(
                        text: 'FiftyChat',
                        style: TextStyle(
                          color: Color(0xFF5CB85C), // Тот самый зеленый
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(flex: 2), // Пружина между текстом и полем ввода

              // Твой виджет ввода с логикой перехода
              ChatInputSection(onSendPressed: _handleInitialMessage),
            ],
          ),

          // Показываем крутилку поверх всего, пока идет запрос
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF5CB85C)),
              ),
            ),
        ],
      ),
    );
  }
}