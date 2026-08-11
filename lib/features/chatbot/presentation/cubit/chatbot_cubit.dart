import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/chatbot_remote_datasource.dart';
import '../../data/models/chat_message_model.dart';
import '../../domain/entities/chat_message_entity.dart';

part 'chatbot_state.dart';

class ChatbotCubit extends Cubit<ChatbotState> {
  final ChatbotRemoteDataSource _dataSource;

  static const _systemMessage = ChatMessageModel(
    role: 'system',
    content:
        'You are Aura, a smart shopping assistant for Aura Shop. '
        'Help users find products, compare items, get recommendations, '
        'and answer shopping-related questions. Be friendly, concise, and helpful.',
  );

  final List<ChatMessageModel> _history = [_systemMessage];

  ChatbotCubit(this._dataSource) : super(ChatbotInitial());

  List<ChatMessageEntity> get messages =>
      _history.where((m) => m.role != 'system').toList();

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessageModel(role: 'user', content: text.trim());
    _history.add(userMsg);
    emit(ChatbotTyping(List.from(messages)));

    try {
      final reply = await _dataSource.sendMessage(_history);
      _history.add(ChatMessageModel(role: 'assistant', content: reply));
      emit(ChatbotLoaded(List.from(messages)));
    } catch (e) {
      _history.removeLast();
      emit(ChatbotError(List.from(messages), e.toString()));
    }
  }

  void clearChat() {
    _history
      ..clear()
      ..add(_systemMessage);
    emit(ChatbotInitial());
  }
}
