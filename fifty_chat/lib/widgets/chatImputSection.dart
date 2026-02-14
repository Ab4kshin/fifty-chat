import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

class ChatImputSection extends StatelessWidget {
  const ChatImputSection({super.key});

  static final ImagePicker _picker = ImagePicker();

  // 2. Функция для открытия галереи
  Future<void> _openGallery() async {
    try {
      // Вызываем галерею
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Опционально: сжимаем фото, чтобы не висло
      );

      if (image != null) {
        print('Файл выбран: ${image.path}');
        // Здесь позже добавим логику отображения картинки в чате
      } else {
        print('Пользователь отменил выбор');
      }
    } catch (e) {
      print('Ошибка при выборе фото: $e');
    }
  }


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
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Чтобы колонка не занимала весь экран
      children: [
        // 1. Ряд быстрых кнопок
        SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Чтобы кнопки можно было листать вбок
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildQuickButton('Галерея промптов', () => _launchURL('https://chat.fifty.su/prompts')), 
              const SizedBox(width: 8),
              _buildQuickButton('Документация API', () => _launchURL('https://chat.fifty.su/api')),
              const SizedBox(width: 8),
              _buildQuickButton('Новости проекта', () => _launchURL('https://t.me/fiftysu')),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Поле ввода
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF262626), // Темный фон как у кнопки Войти
              borderRadius: BorderRadius.circular(25), // Овальная форма
              border: Border.all(color: Colors.white10), // Тонкая рамка
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white70),
                  onPressed: () {
                    // Вызываем функцию открытия галереи
                    _openGallery(); 
                      },
                    ),
                const SizedBox(width: 12),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Задайте любой вопрос...',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                      border: InputBorder.none, // Убираем стандартную линию снизу
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white), // Самолетик/стрелка
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Вспомогательный метод для создания кнопок-чипсов
  Widget _buildQuickButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
