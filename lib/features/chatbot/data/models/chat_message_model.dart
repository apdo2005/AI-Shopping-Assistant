import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({required super.role, required super.content});

  factory ChatMessageModel.fromEntity(ChatMessageEntity entity) {
    return ChatMessageModel(role: entity.role, content: entity.content);
  }

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}
