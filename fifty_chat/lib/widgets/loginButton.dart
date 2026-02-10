import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (){
        print('asd'); // TODO Сделать экран авторизации
      },
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFF262626),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        )
      ),
      child: Text(
        'Войти',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }
}