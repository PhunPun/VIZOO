import 'package:flutter/material.dart';
import 'package:vizoo_frontend/pages/login/widgets/login_body.dart';
import 'package:vizoo_frontend/pages/login/widgets/login_header.dart';
import 'package:vizoo_frontend/widgets/background_login.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
            BackgroundLogin(),
            SafeArea(
              child: SizedBox.expand(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    LoginHeader(),
                    LoginBody()
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}