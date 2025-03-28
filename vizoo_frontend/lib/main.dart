import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vizoo_frontend/pages/my_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Trong suốt
    statusBarIconBrightness: Brightness.dark, // Đổi màu icon (light = icon trắng, dark = icon đen)
    systemNavigationBarColor: Colors.transparent, // Làm trong suốt hoặc đổi thành màu nền
    systemNavigationBarDividerColor: Colors.transparent,
  ));
  runApp(const MyApp());
}

