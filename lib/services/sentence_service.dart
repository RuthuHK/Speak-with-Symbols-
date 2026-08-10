// import 'dart:convert';
// import 'package:http/http.dart' as http;

// Future<String> generateSentence(List<String> selectedWords) async {
//   final url = Uri.parse('http://10.30.201.36:5000/generate');// Replace with your system IP

//   final response = await http.post(
//     url,
//     headers: {'Content-Type': 'application/json'},
//     body: jsonEncode({'words': selectedWords}),
//   );

//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     return data['sentence'] ?? 'No sentence generated.';
//   } else {
//     throw Exception('Failed to generate sentence');
//   }
// }

// // Future<String> translateText(String text, String langCode) async {
// //   // Optional if you want to reuse backend translation
// //   return text; // or refactor backend to send translated data
// // }
// Future<String> generateSentence(List<String> selectedWords) async {
//   final url = Uri.parse('http://10.30.201.36:5000/generate');

//   final response = await http.post(
//     url,
//     headers: {'Content-Type': 'application/json'},
//     body: jsonEncode({'words': selectedWords}),
//   );

//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     return data['sentence'] ?? 'No sentence generated.';
//   } else {
//     throw Exception('Failed to generate sentence');
//   }
// }
// print('🔁 Response from server: ${response.body}');

// lib/services/sentence_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../models/icon_category.dart';

const String apiUrl =
    "http://127.0.0.1:5000/generate"; // ✅ Correct IP from Flask logs
// Replace with your backend IP

Future<String> generateSentence(List<String> selectedWords) async {
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"words": selectedWords}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print("🔁 Response from server: ${data['sentence']}");
    return data['sentence'];
  } else {
    throw Exception("Failed to generate sentence");
  }
}

Future<List<IconCategory>> loadCategories() async {
  final String jsonString = await rootBundle.loadString(
    'assets/icon_categories.json',
  );
  final List<dynamic> jsonData = json.decode(jsonString);
  return jsonData.map((e) => IconCategory.fromJson(e)).toList();
}

Future<String> translateText(String sentence, String langCode) async {
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "words": [],
      "translate_only": true,
      "sentence": sentence,
      "lang": langCode,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['translation'];
  } else {
    throw Exception("Failed to translate");
  }
}
