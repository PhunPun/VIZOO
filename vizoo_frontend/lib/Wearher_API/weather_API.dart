// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class WeatherService {
//   static const String _apiKey = 'ed57a6779f4f51b754bb2c73ce7344b0';
//
//   static Future<Map<String, dynamic>> fetchWeather(String city) async {
//     final url = 'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$_apiKey&units=metric&lang=vi';
//
//     final response = await http.get(Uri.parse(url));
//
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Không thể tải dữ liệu thời tiết (HTTP ${response.statusCode})');
//     }
//   }
// }



import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class WeatherService {
  static const _apiKey = 'ed57a6779f4f51b754bb2c73ce7344b0';
  static Future<Map<String, dynamic>> fetchWeather(String cityName) async {
    final trimmed = cityName.trim();
    if (trimmed.isEmpty) {
      throw Exception('fetchWeather: cityName rỗng');
    }
    // Sử dụng Uri.https để tự mã hóa params
    final uri = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/forecast',
      {
        'q': trimmed,
        'appid': _apiKey,
        'units': 'metric',
        'lang': 'vi',
      },
    );
    debugPrint('Weather API: $uri');
    final res = await http.get(uri);
    debugPrint('Response ${res.statusCode}: ${res.body}');
    if (res.statusCode == 200) {
      return json.decode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }
}

