import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vizoo_frontend/pages/forgot_password/widgets/forgot_password_body.dart';
import 'package:vizoo_frontend/widgets/background_login.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Icon đen
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
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
                child: Column(children: [ForgotPasswordBody()]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
