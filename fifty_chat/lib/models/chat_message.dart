class ChatMessage {
  final String text;
  final bool isUser; // true - если это ты, false - если AI

  ChatMessage({required this.text, required this.isUser});
}