import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/pages/forgot_password/widgets/verification.dart';
import 'package:vizoo_frontend/pages/login/widgets/auth_service.dart';
import 'email_service.dart';
import 'dart:math';

class ForgotPasswordBody extends StatefulWidget {
  const ForgotPasswordBody({super.key});

  @override
  State<ForgotPasswordBody> createState() => _ForgotPasswordBodyState();
}

String generateOtp({int length = 6}) {
  final random = Random();
  return List.generate(length, (_) => random.nextInt(10)).join();
}

class _ForgotPasswordBodyState extends State<ForgotPasswordBody> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();

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
              controller: _emailController,
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
            onPressed: () async {
              String email = _emailController.text.trim();
              final name = email.split('@').first;
              final otp = generateOtp();

              bool success = await EmailService.sendOtpEmail(
                name: name,
                email: email,
                otp: otp,
              );
              if (success) {
                showVerificationDialog(context, email, otp); // bạn cần sửa showVerificationDialog để truyền OTP
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Mã xác thực đã được gửi đến email")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gửi email thất bại")),
                );
              }

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