import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
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
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/search.svg'
                    ),
                    const SizedBox(width: 15,),
                    SvgPicture.asset(
                      'assets/icons/fillter.svg'
                    ),
                  ],
                )  
              ],
            ),
          )
        ],
      ),
    );
  }
}