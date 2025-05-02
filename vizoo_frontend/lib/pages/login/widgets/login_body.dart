import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/apps/router/router_name.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class LoginBody extends StatefulWidget {
  const LoginBody({super.key});


  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 130),
          Text(
            'Login',
            style: TextStyle(
              color: Color(MyColor.pr5),
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 50, right: 50, top: 30),
            constraints: BoxConstraints(maxHeight: 38),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 0,
                ),
                hintText: 'Email',
                hintStyle: TextStyle(color: Color(MyColor.pr5), fontSize: 16),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(MyColor.pr5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(MyColor.black)),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 50, right: 50, top: 30),
            constraints: BoxConstraints(maxHeight: 38),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 0,
                ),
                hintText: 'Password',
                hintStyle: TextStyle(color: Color(MyColor.pr5), fontSize: 16),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(MyColor.pr5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(MyColor.black)),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 55, top: 15),
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                context.goNamed(RouterName.forgotPassword);
              },
              child: Text(
                'Forgot Password?',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Color(MyColor.black),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              String email = _emailController.text.trim();
              String password = _passwordController.text.trim();
              User? user = await _authService.signInWithEmail(email, password);

              if (user != null) {
                final uid = user.uid;
                final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                final data = snapshot.data();

                if (data != null && data.containsKey('role')) {
                  final role = data['role'];

                  if (role == 'admin') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đăng nhập thành công")),
                    );
                    context.goNamed(RouterName.admin); // Chuyển tới trang Admin
                  } else if (role == 'user') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đăng nhập thành công")),
                    );
                    context.goNamed(RouterName.home); // Chuyển tới trang Home
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Role không hợp lệ")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Không tìm thấy thông tin người dùng")),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đăng nhập thất bại")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(MyColor.pr4),
              minimumSize: const Size(135, 37),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Vizoo',
              style: TextStyle(
                color: Color(MyColor.white),
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/icons/FB.svg'),
              const SizedBox(width: 20),
              InkWell(
                onTap: () async {
                  try {
                    User? user = await _authService.signInWithGoogle();
                    if (user != null) {
                      final uid = user.uid;
                      final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                      final data = snapshot.data();

                      if (data != null && data.containsKey('role')) {
                        final role = data['role'];

                        if (role == 'admin') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Đăng nhập thành công")),
                          );
                          context.goNamed(RouterName.admin);
                        } else if (role == 'user') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Đăng nhập thành công")),
                          );
                          context.goNamed(RouterName.home);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Role không hợp lệ")),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Không tìm thấy thông tin người dùng")),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Đăng nhập thất bại")),
                      );
                    }
                  } catch (e) {
                    print('Lỗi khi đăng nhập Google: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi: ${e.toString()}")),
                    );
                  }
                },
                child: SvgPicture.asset('assets/icons/Gmail.svg'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'or',
                style: TextStyle(
                  color: Color(MyColor.black),
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(width: 5),
              InkWell(
                onTap: () {
                  context.goNamed(RouterName.register);
                },
                child: SvgPicture.asset('assets/icons/register.svg'),
              ),
              const SizedBox(width: 25),
            ],
          ),
        ],
      ),
    );
  }
}
