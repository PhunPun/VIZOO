import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/widgets/location_list.dart';


class HomeHotLocations extends StatefulWidget {
  const HomeHotLocations({super.key});

  @override
  State<HomeHotLocations> createState() => _HomeHotLocationsState();
}

class _HomeHotLocationsState extends State<HomeHotLocations> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 10,),
          Row(
            children: [
              const SizedBox(width: 15,),
              SvgPicture.asset(
                'assets/icons/location.svg'
              ),
              const SizedBox(width: 5,),
              Text(
                'Hot locations',
                style: TextStyle(
                  color: Color(MyColor.pr5),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic
                ),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 3),
            width: double.infinity,
            height: 1,
            color: Color(MyColor.pr5),
          ),
          LocationList(),
          Container(
            margin: EdgeInsets.symmetric(vertical: 3),
            width: double.infinity,
            height: 1,
            color: Color(MyColor.pr5),
          ),
        ],
      ),
    );
  }
}

