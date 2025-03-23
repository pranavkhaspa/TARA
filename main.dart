import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> callHuggingFaceProxy() async {
  final url = Uri.parse("http://localhost:8000/evaluate");
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "inputs": "Hello, how are you?",
    }),
  );

  if (response.statusCode == 200) {
    print("Response: ${response.body}");
  } else {
    print("Error: ${response.statusCode}");
  }
}
