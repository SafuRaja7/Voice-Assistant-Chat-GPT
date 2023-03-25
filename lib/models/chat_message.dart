enum ChatMessageType {
  user,
  bot,
  keyboard,
}

class ChatMessage {
  String? text;
  ChatMessageType? type;

  ChatMessage({
    required this.text,
    required this.type,
  });
}
