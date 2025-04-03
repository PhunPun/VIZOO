import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vizoo_frontend/pages/register/widgets/register_body.dart';
import 'package:vizoo_frontend/pages/register/widgets/register_header.dart';
import 'package:vizoo_frontend/widgets/background_login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Icon đen
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            BackgroundLogin(),
            SafeArea(
              child: SizedBox.expand(
                child: Column(children: [RegisterHeader(), RegisterBody()]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
