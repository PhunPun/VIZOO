import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Hearder extends StatelessWidget {
  const Hearder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 14,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                  'assets/icons/logo.svg',
                  width: 98.79,
                  height: 28.26,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}