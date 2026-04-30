import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

class ChatInputSection extends StatefulWidget {
  final Function(String text, String? b64Image) onSendPressed;

  const ChatInputSection({super.key, required this.onSendPressed});

  @override
  State<ChatInputSection> createState() => _ChatInputSectionState();
}

class _ChatInputSectionState extends State<ChatInputSection> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _base64Image; // Сюда сохраним картинку

  // Функция выбора картинки
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Сжимаем, чтобы не перегружать API
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes);
      });
    }
  }

  // Отправка сообщения
void _handleSend() {
    final text = _controller.text.trim();
    
    // Если текста нет И картинки нет — ничего не делаем
    if (text.isEmpty && _base64Image == null) return;

    // 2. ПЕРЕДАЕМ ИМЕННО _base64Image (с подчеркиванием, как назвали выше)
    widget.onSendPressed(text, _base64Image); 

    _controller.clear();
    
    // 3. ОЧИЩАЕМ КАРТИНКУ ПОСЛЕ ОТПРАВКИ
    setState(() {
      _base64Image = null; 
    });
  }

  // // Открытие галереи
  // Future<void> _openGallery() async {
  //   try {
  //     final XFile? image = await _picker.pickImage(
  //       source: ImageSource.gallery,
  //       imageQuality: 80,
  //     );

  //     if (image != null) {
  //       debugPrint('Файл выбран: ${image.path}');
  //       // Здесь можно добавить логику отправки картинки
  //     }
  //   } catch (e) {
  //     debugPrint('Ошибка при выборе фото: $e');
  //   }
  // }

  // Открытие ссылок
void _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) throw 'Не получилось запустить $url';
}

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_base64Image != null)
          Image.memory(base64Decode(_base64Image!), height: 100),
        // 1. Быстрые кнопки (Чипсы)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
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
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                // Кнопка Плюс (Галерея)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white70),
                  onPressed: _pickImage,
                ),
                
                // Самое поле ввода
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _handleSend(),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Задайте любой вопрос...',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                
                // Кнопка Отправить (Стрелочка)
                IconButton(
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                  onPressed: () {
                    if (_controller.text.isNotEmpty || _base64Image != null) {
                  // ПЕРЕДАЕМ ДВА ПАРАМЕТРА
                  widget.onSendPressed(_controller.text, _base64Image);
                  _controller.clear();
                  setState(() => _base64Image = null);
                    }
                  }
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Важно очищать контроллер для памяти
    super.dispose();
  }
}