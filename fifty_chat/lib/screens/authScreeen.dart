import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Future<void> _launchURL(String url) async {
//   final Uri uri = Uri.parse(url);
//   try {
//     // mode: LaunchMode.externalApplication — это КЛЮЧЕВОЙ момент. 
//     // Он говорит системе: "Просто открой нормальный браузер Safari"
//     await launchUrl(uri, mode: LaunchMode.externalApplication);
//   } catch (e) {
//     print('Ошибка при запуске: $e');
//   }
// }
void _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) throw 'Не получилось запустить $url';
}

class AuthScreeen extends StatelessWidget {
  const AuthScreeen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF161616),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white,),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 2,),
          const Text(
            'Выберите сервис авторизации',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            _authTile(imagePath: 'lib/assets/icons/github.png', label: 'Github', onTap: () => _launchURL('https://github.com/ab4kshin/fifty-chat')),
            _authTile(imagePath: 'lib/assets/icons/google.png', label: 'Google', onTap: () => _launchURL('https://google.com')),
            _authTile(imagePath: 'lib/assets/icons/vk.png', label: 'VK', onTap: () => _launchURL('https://vk.ru')),
            const Spacer(flex: 3,)
        ],
        ),
      ),
    );
  }
}

Widget _authTile({
  required String imagePath, 
  required String label, 
  required VoidCallback onTap, // Добавляем новый параметр для действия
}) {
  return Container(
    width: 280, // Немного увеличим ширину для солидности
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Material( // Material нужен, чтобы эффект нажатия (InkWell) был виден
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap, // Сюда передаем функцию нажатия
        borderRadius: BorderRadius.circular(30), // Скругляем эффект нажатия
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF262626), // Твой цвет
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Image.asset(imagePath, width: 24, height: 24),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}