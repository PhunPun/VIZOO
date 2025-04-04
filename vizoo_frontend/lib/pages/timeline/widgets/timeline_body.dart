import 'package:flutter/material.dart';
import 'package:vizoo_frontend/pages/timeline/widgets/set_day_start.dart';
import 'package:vizoo_frontend/pages/timeline/widgets/set_people_num.dart';
import 'package:vizoo_frontend/widgets/trip_card.dart';

class TimelineBody extends StatefulWidget {
  final String address; // dia diem
  final String imageUrl; //
  final String dayNum; // so ngay
  final int activitiesNum; // so hoat dong
  final int mealNum; // so bua an
  final int peopleNum; // so nguoi
  final String residence; // noi o
  final int cost; // chi phi
  final int rating; // danh gia

  const TimelineBody({
    super.key,
    required this.address,
    required this.imageUrl,
    required this.dayNum,
    required this.activitiesNum,
    required this.mealNum,
    required this.peopleNum,
    required this.residence,
    required this.cost,
    required this.rating,
  });

  @override
  State<TimelineBody> createState() => _TimelineBodyState();
}

class _TimelineBodyState extends State<TimelineBody> {
  late int activitiesNum;
  late int mealNum;
  late int peopleNum;
  late String residence;
  late int cost;
  @override
  void initState(){
    super.initState();
    activitiesNum = widget.activitiesNum;
    mealNum = widget.mealNum;
    peopleNum = widget.peopleNum;
    residence = widget.residence;
    cost = widget.cost;
  }
  void onSetPeople(int newCount) {
    setState(() {
      peopleNum = newCount;
    });
  }

  void onSetCost(int newCost) {
    setState(() {
      cost = newCost;
    });
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          TripCard(
            address: widget.address,
            imageUrl: widget.imageUrl,
            dayNum: widget.dayNum,
            activitiesNum: activitiesNum,
            mealNum: mealNum,
            peopleNum: peopleNum,
            residence: residence,
            cost: cost,
            rating: widget.rating,
          ),
          SetPeopleNum(
            peopleNum: peopleNum, 
            cost: cost, 
            onSetPeople: onSetPeople, 
            onSetCost: onSetCost
          ),
          SetDayStart(),
        ],
      ),
    );
  }
}
