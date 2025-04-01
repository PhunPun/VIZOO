import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vizoo_frontend/apps/colors/colors.dart';
import 'package:vizoo_frontend/apps/router/router_name.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40,),
          Row(
            children: [
              const SizedBox(width: 40,),
              Text(
                'or',
                style: TextStyle(
                  color: Color(MyColor.black),
                  fontSize: 20,
                  fontStyle: FontStyle.italic
                ),
              ),
              InkWell(
                onTap: () {
                  context.goNamed(RouterName.login);
                },
                child: SvgPicture.asset(
                  'assets/icons/login.svg'
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}