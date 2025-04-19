import 'package:flutter/material.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/widgets/hearder.dart';
import 'package:vizoo_frontend/widgets/loved_trip_list.dart';
import 'package:vizoo_frontend/widgets/trip_list.dart';

class LovePage extends StatelessWidget {
  const LovePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 38,),
            Hearder(),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Text(
                'Lịch trình đã thích',
                style: TextStyle(
                  color: Color(MyColor.black),
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            LovedTripList(),
            const SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }
}