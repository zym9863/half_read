import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

enum ReasoningEffort { low, medium, high }

enum SummaryStatus { initial, loading, success, error }

class SummaryProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();

  String _originalText = '';
  String _summaryText = '';
  String _errorMessage = '';
  SummaryStatus _status = SummaryStatus.initial;
  ReasoningEffort _reasoningEffort = ReasoningEffort.medium;
  bool _isApiKeySet = false;

  String get originalText => _originalText;
  String get summaryText => _summaryText;
  String get errorMessage => _errorMessage;
  SummaryStatus get status => _status;
  ReasoningEffort get reasoningEffort => _reasoningEffort;
  bool get isApiKeySet => _isApiKeySet;

  SummaryProvider() {
    _checkApiKey();
  }

  Future<void> _checkApiKey() async {
    final apiKey = await _geminiService.getApiKey();
    _isApiKeySet = apiKey != null && apiKey.isNotEmpty;
    notifyListeners();
  }

  Future<void> setApiKey(String apiKey) async {
    await _geminiService.setApiKey(apiKey);
    _isApiKeySet = true;
    notifyListeners();
  }

  void setOriginalText(String text) {
    _originalText = text;
    notifyListeners();
  }

  void setReasoningEffort(ReasoningEffort effort) {
    _reasoningEffort = effort;
    notifyListeners();
  }

  String _getReasoningEffortString() {
    switch (_reasoningEffort) {
      case ReasoningEffort.low:
        return 'low';
      case ReasoningEffort.medium:
        return 'medium';
      case ReasoningEffort.high:
        return 'high';
    }
  }

  Future<void> generateSummary() async {
    if (_originalText.isEmpty) {
      _errorMessage = '请输入文本';
      _status = SummaryStatus.error;
      notifyListeners();
      return;
    }

    _status = SummaryStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _geminiService.generateSummary(
        _originalText,
        _getReasoningEffortString(),
      );

      _summaryText = response.choices.first.message.content;
      _status = SummaryStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = SummaryStatus.error;
    }

    notifyListeners();
  }

  void reset() {
    _originalText = '';
    _summaryText = '';
    _errorMessage = '';
    _status = SummaryStatus.initial;
    notifyListeners();
  }
}
