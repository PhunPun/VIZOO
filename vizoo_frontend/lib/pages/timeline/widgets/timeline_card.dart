import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class TimelineCard extends StatelessWidget {
  final TimeOfDay time;
  final String activities;
  final String address;
  final int price;
  final bool completed;
  final String categories;
  final VoidCallback? onTap;

  const TimelineCard({
    super.key,
    required this.time,
    required this.activities,
    required this.address,
    required this.price,
    required this.completed,
    required this.categories,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(
              width: 4,
              color: Color(MyColor.pr3)
            ),
            bottom: BorderSide(
              width: 0.5,
              color: Color(MyColor.pr3)
            )
          )
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  time.format(context),
                style: const TextStyle(
                    color: Color(MyColor.pr4),
                    fontSize: 18,
                    fontWeight: FontWeight.w500
                  ),
                ),
              )
            ),
            Expanded(
              flex: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activities,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.0,
                      fontWeight: FontWeight.w400,
                      color: Color(MyColor.black)
                    ),
                  ),
                  Text(
                    address,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.0,
                      fontWeight: FontWeight.w400,
                      color: Color(MyColor.grey)
                    ),
                  ),
                ],
              )
            ),
            Expanded(
              flex: 4,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  textAlign: TextAlign.end,
                  "${NumberFormat("#,###", "vi_VN").format(price)}đ",
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.0,
                    fontWeight: FontWeight.w600,
                    color: Color(MyColor.pr4)
                  ),
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}