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
  const TimelineCard({
    super.key,
    required this.time,
    required this.activities,
    required this.address,
    required this.price,
    required this.completed
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            width: 4,
            color: Color(MyColor.pr3)
          ),
          bottom: BorderSide(
            width: 0.2,
            color: Color(MyColor.pr3)
          )
        )
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
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
            flex: 7,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      textAlign: TextAlign.end,
                      "${NumberFormat("#,###", "vi_VN").format(price)}đ",
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.0,
                        fontWeight: FontWeight.w600,
                        color: Color(MyColor.pr4)
                      ),
                    ),
                  ],
                ),
              ],
            )
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.center,
              child: SvgPicture.asset(
                completed
                ? 'assets/icons/done.svg' 
                : 'assets/icons/note.svg'
              )
            )
          ),
        ],
      ),
    );
  }
}