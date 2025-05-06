class SummaryRequest {
  final String model;
  final String reasoningEffort;
  final List<Map<String, String>> messages;

  SummaryRequest({
    required this.model,
    required this.reasoningEffort,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'reasoning_effort': reasoningEffort,
      'messages': messages,
    };
  }
}

class SummaryResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<Choice> choices;
  final Usage usage;

  SummaryResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
  });

  factory SummaryResponse.fromJson(Map<String, dynamic> json) {
    return SummaryResponse(
      id: json['id'],
      object: json['object'],
      created: json['created'],
      model: json['model'],
      choices: (json['choices'] as List)
          .map((choice) => Choice.fromJson(choice))
          .toList(),
      usage: Usage.fromJson(json['usage']),
    );
  }
}

class Choice {
  final int index;
  final Message message;
  final String finishReason;

  Choice({
    required this.index,
    required this.message,
    required this.finishReason,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      index: json['index'],
      message: Message.fromJson(json['message']),
      finishReason: json['finish_reason'],
    );
  }
}

class Message {
  final String role;
  final String content;

  Message({
    required this.role,
    required this.content,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'],
      content: json['content'],
    );
  }

  Map<String, String> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}

class Usage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  Usage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      promptTokens: json['prompt_tokens'],
      completionTokens: json['completion_tokens'],
      totalTokens: json['total_tokens'],
    );
  }
}