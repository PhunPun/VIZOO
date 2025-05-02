import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  static const String serviceId = 'Vizoo';
  static const String templateId = 'Vizoo';
  static const String userId = 'hU9Ci0q8gXOLrSGOa';

  static Future<bool> sendOtpEmail({
    required String name,
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'to_email': email,
            'name': name,
            'otp': otp,
          },
        }),
      );
      print("Gửi đến: $email");
      print('EmailJS response: ${response.statusCode}');
      print('EmailJS body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi gửi OTP: $e");
      return false;
    }
  }
}
