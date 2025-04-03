import 'package:flutter/material.dart';
import 'package:vizoo_frontend/apps/colors/colors.dart';

class LocationsCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  const LocationsCard({
    super.key,
    required this.name,
    required this.imageUrl
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
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover
              )
            ),
          ),
          Positioned(
            bottom: 3,
            left: 3,
            child: Text(
              name,
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