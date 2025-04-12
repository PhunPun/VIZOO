import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vizoo_frontend/models/timeline_model.dart';
import 'package:vizoo_frontend/pages/edit_timeline/edit_timeline_page.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/widgets/timeline_card.dart';

class TimelineList extends StatelessWidget {
  final int numberDay;
  TimelineList({
    super.key,
    required this.numberDay
  });
  final Map<int, List<TimelineModel>> allTimelines = TimelineModel.getAllTimelinesByDay();

  @override
  Widget build(BuildContext context) {
    final timelines = allTimelines[numberDay] ?? [];
    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
          padding: const EdgeInsets.only(top: 13, left: 8, right: 8, bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(MyColor.pr5)),
          ),
          child: Column(
            children: timelines.map((timeline){
              return TimelineCard(
                time: timeline.time, 
                activities: timeline.activities, 
                address: timeline.address, 
                price: timeline.price, 
                completed: timeline.completed,
                categories: timeline.categories,
                onTap: () {
                  // Điều hướng đến trang chi tiết
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTimelinePage(
                        time: timeline.time,
                        activities: timeline.activities,
                        address: timeline.address,
                        price: timeline.price,
                        completed: timeline.completed,
                        categories: timeline.categories
                      ),
                    ),
                  );
                },
              );
            }).toList()
          ),
        ),
        Positioned(
          top: 0,
          left: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Color(MyColor.white),
              borderRadius: BorderRadius.circular(33),
              boxShadow: [
                BoxShadow(
                  color: Color(MyColor.white),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: Offset(0, 0)
                )
              ]
            ),
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Day $numberDay',
              style: TextStyle(
                fontSize: 20,
                color: Color(MyColor.pr5)
              ),
            ),
          ),
        ),
      ],
    );
  }
}