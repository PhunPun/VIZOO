import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/apps/router/router_name.dart';

class ChangePasswordBody extends StatefulWidget {
  const ChangePasswordBody({super.key});

  @override
  State<ChangePasswordBody> createState() => _ChangePasswordBodyState();
}

class _ChangePasswordBodyState extends State<ChangePasswordBody> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 150,),
          Text(
            textAlign: TextAlign.center,
            'Your password must be at-least \n8 characters long',
            style: TextStyle(
              color: Color(MyColor.black),
              fontSize: 20,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 50, right: 50, top: 30),
            constraints: BoxConstraints(maxHeight: 38),
            child: TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                hintText: 'Enter new password',
                hintStyle: TextStyle(
                  color: Color(MyColor.pr5),
                  fontSize: 16
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Color(MyColor.pr5)
                  )
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Color(MyColor.black)
                  )
                )
              ),
            ),
          ), 
          Container(
            margin: EdgeInsets.only(left: 50, right: 50, top: 25),
            constraints: BoxConstraints(maxHeight: 38),
            child: TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                hintText: 'Confirm new password',
                hintStyle: TextStyle(
                  color: Color(MyColor.pr5),
                  fontSize: 16
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Color(MyColor.pr5)
                  )
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Color(MyColor.black)
                  )
                )
              ),
            ),
          ),
          const SizedBox(height: 40,), 
          ElevatedButton(
            onPressed: () {
              context.goNamed(RouterName.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(MyColor.pr4),
              minimumSize: Size(222, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25)
              )
            ),
            child: Text(
              'Change password',
              style: TextStyle(
                color: Color(MyColor.black),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic
              ),
            ),
          ),
          const SizedBox(height: 55,),
          Text(
            'Login with',
            style: TextStyle(
              color: Color(MyColor.black),
              fontSize: 17,
              fontWeight: FontWeight.w600
            ) ,
          ),
          const SizedBox(height: 25,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/FB.svg'
              ),
              const SizedBox(width: 20,),
              SvgPicture.asset(
                'assets/icons/Gmail.svg'
              )
            ],
          ),
        ],
      ),
    );
  }
}