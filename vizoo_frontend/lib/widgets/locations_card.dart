import 'package:flutter/material.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class LocationsCard extends StatelessWidget {
  final String ten;
  final String hinhAnh1;
  const LocationsCard({
    super.key,
    required this.ten,
    required this.hinhAnh1
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8),
      child: Stack(
        children: [
          Container(
            width: 92,
            height: 137,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(hinhAnh1),
                fit: BoxFit.cover
              )
            ),
          ),
          Positioned(
            bottom: 3,
            left: 3,
            child: Text(
              ten,
              style: TextStyle(
                color: Color(MyColor.white),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    blurRadius: 4.0,
                    color: Color(MyColor.black),
                    offset: Offset(2, 2)
                  )
                ]
              ),
            ),
          )
        ],
      ),
    );
  }
}