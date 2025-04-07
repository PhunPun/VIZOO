import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vizoo_frontend/apps/colors/colors.dart';

class RegisterBody extends StatefulWidget {
  const RegisterBody({super.key});

  @override
  State<RegisterBody> createState() => _RegisterBodyState();
}

class _RegisterBodyState extends State<RegisterBody> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 115,),
          Text(
            'Login',
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
            onPressed: () {
              //TODO: dieu huong
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