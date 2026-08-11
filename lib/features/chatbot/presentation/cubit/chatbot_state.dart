part of 'chatbot_cubit.dart';

abstract class ChatbotState {
  final List<ChatMessageEntity> messages;
  const ChatbotState(this.messages);
}

class ChatbotInitial extends ChatbotState {
  ChatbotInitial() : super(const []);
}

class ChatbotLoaded extends ChatbotState {
  const ChatbotLoaded(super.messages);
}

class ChatbotTyping extends ChatbotState {
  const ChatbotTyping(super.messages);
}

class ChatbotError extends ChatbotState {
  final String error;
  const ChatbotError(super.messages, this.error);
}
