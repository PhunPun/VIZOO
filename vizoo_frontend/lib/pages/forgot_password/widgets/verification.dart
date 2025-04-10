import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/apps/router/router_name.dart';

void showVerificationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog( // Đổi từ AlertDialog sang Dialog để dễ chỉnh kích thước
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Color(MyColor.pr1), // Màu nền be nhạt
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, // Chiếm 90% chiều rộng màn hình
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Verification",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "A verification code has been sent to your email",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  hintText: "Verification code",
                  filled: true,
                  fillColor: Color(MyColor.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  context.goNamed(RouterName.changePassword);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(MyColor.pr3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Reset Password",
                  style: TextStyle(
                    color: Color(MyColor.black),
                    fontSize: 13,
                    fontStyle: FontStyle.italic
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Change Email",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Color(MyColor.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

