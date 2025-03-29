import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vizoo_frontend/apps/colors/colors.dart';
import 'package:vizoo_frontend/pages/forgot_password/widgets/verification.dart';

class ForgotPasswordBody extends StatefulWidget {
  const ForgotPasswordBody({super.key});

  @override
  State<ForgotPasswordBody> createState() => _ForgotPasswordBodyState();
}

class _ForgotPasswordBodyState extends State<ForgotPasswordBody> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 150,),
          Text(
            'Forgot Password',
            style: TextStyle(
              color: Color(MyColor.pr5),
              fontSize: 30,
              fontWeight: FontWeight.w700
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 50, right: 50, top: 30),
            constraints: BoxConstraints(maxHeight: 50),
            child: TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                hintText: 'Email',
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
          const SizedBox(height: 20,),
          ElevatedButton(
            onPressed: () {
              showVerificationDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(MyColor.pr3),
              minimumSize: Size(251, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              )
            ),
            child: Text(
              'Send Code',
              style: TextStyle(
                color: Color(MyColor.black),
                fontSize: 19,
                fontWeight: FontWeight.w700
              ),
            ),
          ),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Try anotherway?',
                style: TextStyle(
                  color: Color(MyColor.black),
                  fontSize: 17,
                  fontStyle: FontStyle.italic
                ),
              ),
              const SizedBox(width: 25,)
            ],
          ),
          const SizedBox(height: 45,),
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