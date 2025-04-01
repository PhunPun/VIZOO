import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BackgroundLogin extends StatelessWidget {
  const BackgroundLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
          ),
          Positioned(
            right: 10,
            top: 160,
            child: SvgPicture.asset(
              'assets/icons/logo.svg'
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/images/Ellipse.png'
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              'assets/images/coconut_tree.png'
            ),
          )
        ],
      ),
    );
  }
}