import 'package:flutter/material.dart';
import 'package:vizoo_frontend/pages/admin/widgets/admin_fillter_trip_list.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class AdminTripBody extends StatefulWidget {
  final Map<String, dynamic> filters;
  const AdminTripBody({super.key, this.filters = const {}});

  @override
  State<AdminTripBody> createState() => _AdminTripBodyState();
}

class _AdminTripBodyState extends State<AdminTripBody> {
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
          AdminFillterTripList(filters: widget.filters,),
          const SizedBox(height: 20,),
        ],
      ),
    );
  }
}