import 'package:flutter/material.dart';
import '../widgets/loginButton.dart';
import '../widgets/chatImputSection.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Чтобы фон был под AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          LoginButton(),
          SizedBox(width: 10),
        ],
      ),
      // Всё, что на экране, запихиваем в ОДНУ колонку
      body: Column(
        children: [
          const Spacer(flex: 3), // Пружина сверху (цифра 3 значит, что она давит сильнее)

          // Твой текст теперь внутри колонки
          Center( 
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Привет, я ', // Поправил на русский
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32, 
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const TextSpan(
                    text: 'FiftyChat',
                    style: TextStyle(
                      color: Color(0xFF5CB85C),
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

          // Твой новый виджет ввода в самом низу
          const ChatImputSection(), 
        ],
      ),
    );
  }
}