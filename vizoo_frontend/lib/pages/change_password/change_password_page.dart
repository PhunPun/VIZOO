import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vizoo_frontend/pages/change_password/widgets/change_password_body.dart';
import 'package:vizoo_frontend/widgets/background_login.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Icon đen
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
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
                child: Column(children: [ChangePasswordBody()]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
