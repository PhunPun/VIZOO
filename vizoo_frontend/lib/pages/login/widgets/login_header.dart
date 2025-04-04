import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15,),
          Row(
            children: [
              const SizedBox(width: 40,),
              Text(
                'Welcome \nback!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(MyColor.black),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.0
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}