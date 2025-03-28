import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/logo.svg'
            )
          ],
        ),
      ],
    );
  }
}