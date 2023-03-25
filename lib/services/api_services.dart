import 'dart:convert';

import 'package:http/http.dart' as http;

String apiKey = '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';

class ApiServices {
  static String baseUrl = "https://api.openai.com/v1/completions";

  static Future<dynamic> sendMessage({String? message}) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

      final requestBody = jsonEncode(
        <String, dynamic>{
          "model": "text-davinci-003",
          "prompt": message,
          "max_tokens": 100,
        },
      );

      final response = await http.post(
        Uri.parse(
          baseUrl,
        ),
        headers: headers,
        body: requestBody,
      );

      final raw = response.body;
      final jsonRaw = jsonDecode(raw);
      final result = jsonRaw['choices'][0]['text'];

      return result;
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
