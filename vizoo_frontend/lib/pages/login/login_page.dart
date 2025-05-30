import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Icon đen
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: IconButton(
            icon: Icon(
              Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          children: [
            BackgroundLogin(),
            SafeArea(
              child: SizedBox.expand(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [LoginHeader(), LoginBody()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
