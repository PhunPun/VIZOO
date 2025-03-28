import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vizoo_frontend/apps/colors/colors.dart';
import 'package:vizoo_frontend/apps/router/router_name.dart';

class WelcomeBody extends StatelessWidget {
  const WelcomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 150,),
          Image.asset(
            'assets/images/earth.png'
          ),
          Text(
            'What to eat? Where to go?',
            style: TextStyle(
              fontSize: 20,
              color: Color(MyColor.pr5)
            ),
          ),
          Text(
            'Let Vizoo guide you!',
            style: TextStyle(
              fontSize: 20,
              color: Color(MyColor.pr5)
            ),
          ),
          const SizedBox(height: 20,),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.goNamed(RouterName.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(MyColor.pr4),
                    minimumSize: Size(122, 37),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    )
                  ),
                  child: Text(
                    'Get started',
                    style: TextStyle(
                      color: Color(MyColor.white),
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                const SizedBox(width: 20,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}