import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> extractUserIdFromToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('access_token');

  if (token != null) {
    // Split the token into its three parts: header, payload, signature
    final parts = token.split('.');
    if (parts.length == 3) {
      // Decode the base64 payload
      final payload = parts[1];
      String normalizedPayload = base64Url.normalize(payload);
      String decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));

      // Parse the payload as JSON
      final Map<String, dynamic> decodedJson = jsonDecode(decodedPayload);

      // Extract and return the user_id
      return decodedJson['user_id'].toString();
    }
  }
  return null;
}