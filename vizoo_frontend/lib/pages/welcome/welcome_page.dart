import 'package:flutter/material.dart';
import 'package:vizoo_frontend/pages/welcome/widgets/welcome_background.dart';
import 'package:vizoo_frontend/pages/welcome/widgets/welcome_body.dart';
import 'package:vizoo_frontend/pages/welcome/widgets/welcome_header.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          WelcomeBackground(),
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  WelcomeHeader(),
                  WelcomeBody()
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}