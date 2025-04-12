import 'package:flutter/material.dart';
import 'package:vizoo_frontend/pages/timeline/widgets/timeline_body.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/widgets/hearder.dart';

class YourTripPage extends StatelessWidget {
  const YourTripPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 38,),
          Hearder(),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Text(
              'Lịch trình đang tiến hành',
              style: TextStyle(
                color: Color(MyColor.black),
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          TimelineBody(
            address: 'Vũng Tàu',
            imageUrl: 'https://i.pinimg.com/736x/44/5e/30/445e306f9477c2ee8a123aa0d11ae8b3.jpg',
            dayNum: '3 ngày 2 đêm',
            activitiesNum: 15,
            mealNum: 9,
            peopleNum: 1,
            residence: 'Nhà nghỉ Phun',
            cost: 2500000,
            rating: 4,
          )
        ],
      ),
    );
  }
}