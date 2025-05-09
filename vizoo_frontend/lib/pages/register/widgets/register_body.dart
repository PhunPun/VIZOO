import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/apps/router/router_name.dart';
import 'package:vizoo_frontend/pages/login/widgets/auth_service.dart';


class RegisterBody extends StatefulWidget {
  const RegisterBody({super.key});

  @override
  State<RegisterBody> createState() => _RegisterBodyState();
}

class _RegisterBodyState extends State<RegisterBody> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 115,),
          Text(
            'Register',
            style: TextStyle(
                color: Color(MyColor.pr5),
                fontSize: 40,
                fontWeight: FontWeight.bold
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 50, right: 50, top: 20),
            constraints: BoxConstraints(maxHeight: 38),
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  hintText: 'Username',
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
            margin: EdgeInsets.only(left: 50, right: 50, top: 20),
            constraints: BoxConstraints(maxHeight: 38),
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
          Container(
            margin: EdgeInsets.only(left: 50, right: 50, top: 20),
            constraints: BoxConstraints(maxHeight: 38),
            child: TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  hintText: 'Password',
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
            margin: EdgeInsets.only(left: 50, right: 50, top: 20),
            constraints: BoxConstraints(maxHeight: 38),
            child: TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  hintText: 'Confirm Password',
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
            onPressed: () async {
              final email = _emailController.text.trim();
              final password = _passwordController.text.trim();
              final confirmPassword = _confirmPasswordController.text.trim();
              final username = _usernameController.text.trim();

              if (password != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mật khẩu không khớp")));
                return;
              }

              final authService = AuthService();
              final user = await authService.registerWithEmail(email, password, username);

              if (user != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đăng ký thành công")));
                context.goNamed(RouterName.login);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đăng ký thất bại")));
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Color(MyColor.pr4),
                minimumSize: Size(135, 37),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)
                )
            ),
            child: Text(
              'Register',
              style: TextStyle(
                  color: Color(MyColor.white),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic
              ),
            ),
          ),
          const SizedBox(height: 40,),
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