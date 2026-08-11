import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chat_message_model.dart';

abstract class ChatbotRemoteDataSource {
  Future<String> sendMessage(List<ChatMessageModel> messages);
}

class ChatbotRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  late final Dio _dio;

  static String get _apiKey => dotenv.env['API_KEY'] ?? '';
  static const String _model = 'llama-3.3-70b-versatile';
  static const String _baseUrl = 'https://api.groq.com/openai/v1';

  ChatbotRemoteDataSourceImpl() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        validateStatus: (status) => status != null,
      ),
    );

    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (_, __, ___) => true;
        return client;
      },
    );
  }

  @override
  Future<String> sendMessage(List<ChatMessageModel> messages) async {
    final systemPrompt = {
      'role': 'system',
      'content':
          '''You are a helpful grocery shopping assistant. Your ONLY job is to help users find grocery items, check prices, suggest recipes using ingredients, and manage their shopping cart. 
      
      If the user asks about anything completely unrelated to groceries, cooking, or shopping (such as coding, general history, politics, math, etc.), you MUST politely refuse by saying EXACTLY this phrase:
      "عذراً، أنا مساعد خاص بتطبيق البقالة فقط ويمكنني مساعدتك في اختيار المنتجات ووصفات الطعام. هل تبحث عن أي مواد غذائية اليوم؟"
      
      Never answer out-of-scope questions.''',
    };

    final formattedMessages = [
      systemPrompt,
      ...messages.map((m) => m.toJson()).toList(),
    ];

    final response = await _dio.post(
      '/chat/completions',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        responseType: ResponseType.json,
      ),
      data: {'model': _model, 'messages': formattedMessages},
    );

    if (response.statusCode != 200) {
      final error = response.data is Map
          ? (response.data['error']?['message'] ?? 'Unknown error')
          : 'HTTP ${response.statusCode}';
      throw Exception(error);
    }

    return response.data['choices'][0]['message']['content'] as String;
  }
}
