import 'package:flutter/material.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/widgets/fillter_trip_list.dart';
import 'package:vizoo_frontend/widgets/trip_card.dart';
import 'package:vizoo_frontend/widgets/trip_list.dart';

class HomeBody extends StatefulWidget {
  final Map<String, dynamic> filters;
  const HomeBody({super.key, this.filters = const {}});


  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Text(
              'Lịch trình có sẵn',
              style: TextStyle(
                color: Color(MyColor.black),
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          FillterTripList(filters: widget.filters,),
          const SizedBox(height: 20,),
        ],
      ),
    );
  }
}