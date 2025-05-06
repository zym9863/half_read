import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/summary_model.dart';

class GeminiService {
  final String baseUrl = 'https://zym9863-gemini.deno.dev/v1/chat/completions';
  final String model = 'gemini-2.5-flash-preview-04-17';
  String? _apiKey;

  Future<void> setApiKey(String apiKey) async {
    _apiKey = apiKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', apiKey);
  }

  Future<String?> getApiKey() async {
    if (_apiKey != null) return _apiKey;

    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('gemini_api_key');
    return _apiKey;
  }

  Future<SummaryResponse> generateSummary(
    String text,
    String reasoningEffort,
  ) async {
    final apiKey = await getApiKey();
    if (apiKey == null) {
      throw Exception('API密钥未设置');
    }

    final request = SummaryRequest(
      model: model,
      reasoningEffort: reasoningEffort,
      messages: [
        {'role': 'user', 'content': '请为以下文本生成一个简洁的摘要，只保留核心内容：\n\n$text'},
      ],
    );

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return SummaryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('生成摘要失败: ${response.body}');
    }
  }
}
