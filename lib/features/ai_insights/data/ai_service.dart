import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_keys.dart';

class AIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> generateFinancialInsight({
    required double income,
    required double expense,
    required String topCategory,
    required String role,
  }) async {
    try {
      final prompt = '''
You are FinTrack AI, an expert, encouraging, and highly intelligent financial advisor.
The user is a **$role**.
Their monthly statistics:
- Total Income: ₹$income
- Total Expense: ₹$expense
- Top Spending Category: $topCategory

Write a 2-3 sentence personalized financial insight for them. 
If they are a student, focus on avoiding debt, saving pocket money/freelance income, and finding discounts. 
If they are a professional, focus on the 50/30/20 rule, tax optimization, and investments.
If expense > income, give a gentle warning. If income > expense, suggest saving/investing. Be concise and friendly.
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiKeys.openAiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': 'You are a helpful financial assistant.'},
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        return 'Error generating insight: ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Failed to connect to AI Service. Please check your internet connection.';
    }
  }

  Future<String> generatePdfSummary({
    required double income,
    required double expense,
    required String topCategory,
    required String role,
  }) async {
    try {
      final prompt = '''
You are FinTrack AI, an expert financial advisor.
The user is a **$role**.
Their monthly statistics for this PDF report are:
- Total Income: ₹$income
- Total Expense: ₹$expense
- Top Spending Category: $topCategory

Write a detailed, professional, and insightful 2-paragraph financial overview for their monthly report.
The first paragraph should analyze their spending and saving behavior.
The second paragraph should provide actionable, highly personalized advice based on whether they are a student or professional.
Do not use markdown formatting like bolding or headers, just plain text.
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiKeys.openAiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': 'You are a professional financial assistant generating a PDF report summary.'},
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        return 'Overview unavailable at the moment.';
      }
    } catch (e) {
      return 'AI Overview could not be generated due to network connection issues.';
    }
  }

  Future<String> sendChatMessage({
    required String userMessage,
    required double income,
    required double expense,
    required String topCategory,
    required String role,
  }) async {
    try {
      final systemPrompt = '''
You are FinTrack AI, an expert, encouraging, and highly intelligent financial advisor.
The user is a **$role**.
Their monthly stats:
- Income: ₹$income
- Expense: ₹$expense
- Top Category: $topCategory

Answer their financial questions concisely, accurately, and politely. Keep responses under 3 sentences unless asked for details. Tailor your advice to their role (Student vs Professional).
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiKeys.openAiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage}
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        return 'Error communicating with AI: ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Failed to connect to AI Service. Check internet connection.';
    }
  }

  Future<Map<String, dynamic>?> scanReceipt(String base64Image, String role, List<String> categories) async {
    try {
      final prompt = '''
You are FinTrack AI, an expert financial assistant.
Extract the transaction details from the following receipt image.
The user is a **$role**.
Their available categories are: ${categories.join(', ')}.

Respond ONLY with a valid JSON object. Do not wrap it in markdown code blocks.
The JSON must strictly have this schema:
{
  "amount": <number, the final total amount on the receipt>,
  "category": <string, the single best matching category from the available list>,
  "notes": <string, a very short 2-5 word summary of the purchase (e.g., "Starbucks Coffee")>,
  "date": <string, in YYYY-MM-DD format if found, otherwise omit>
}
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiKeys.openAiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': prompt},
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                    'detail': 'low'
                  }
                }
              ]
            }
          ],
          'temperature': 0.1, // Low temperature for consistent JSON extraction
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['choices'][0]['message']['content'].toString().trim();
        // Clean up markdown block if the model accidentally included it
        if (content.startsWith('```json')) {
          content = content.substring(7);
        }
        if (content.startsWith('```')) {
          content = content.substring(3);
        }
        if (content.endsWith('```')) {
          content = content.substring(0, content.length - 3);
        }
        return jsonDecode(content.trim()) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
