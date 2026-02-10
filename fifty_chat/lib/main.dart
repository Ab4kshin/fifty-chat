import 'package:flutter/material.dart';
import 'screens/homeScreenWOauth.dart';

void main() {
  runApp(const FiftyChat());
}
class FiftyChat extends StatelessWidget {
  const FiftyChat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FiftyChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF161616),
        primaryColor: Colors.green,
        ),
        home: HomeScreen(),
      );
  }
}
