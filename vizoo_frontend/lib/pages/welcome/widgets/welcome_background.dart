import 'package:flutter/material.dart';
import 'package:vizoo_frontend/apps/colors/colors.dart';

class WelcomeBackground extends StatelessWidget {
  const WelcomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(MyColor.white),
            Color(MyColor.pr1)
          ]
        )
      ),
    );
  }
}