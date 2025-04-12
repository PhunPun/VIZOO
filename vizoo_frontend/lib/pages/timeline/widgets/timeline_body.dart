import 'package:flutter/material.dart';
import 'package:vizoo_frontend/widgets/set_day_start.dart';
import 'package:vizoo_frontend/widgets/set_people_num.dart';
import 'package:vizoo_frontend/pages/timeline/widgets/timeline_list.dart';
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
  DateTime initDate = DateTime.now();
  int numberDay = 1;
  @override
  void initState(){
    super.initState();
    activitiesNum = widget.activitiesNum;
    mealNum = widget.mealNum;
    peopleNum = widget.peopleNum;
    residence = widget.residence;
    cost = widget.cost;
    caculatorDay();
  }
  void caculatorDay() {
  int newNumberDay = 1; // Default value
  
  if (widget.dayNum.contains('1 ngày')) {
    newNumberDay = 1;
  } 
  else if (widget.dayNum.contains('2 ngày 1 đêm')) {
    newNumberDay = 2;
  }
  else if (widget.dayNum.contains('3 ngày 2 đêm')) {
    newNumberDay = 3;
  }
  else if (widget.dayNum.contains('4 ngày 3 đêm')) {
    newNumberDay = 4;
  }
  else if (widget.dayNum.contains('5 ngày 4 đêm')) {
    newNumberDay = 5;
  }

  if (numberDay != newNumberDay) {
    setState(() {
      numberDay = newNumberDay;
    });
  }
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
  void onChangeDate(DateTime newDate){
    setState(() {
      initDate = newDate;
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
          SetDayStart(
            dateStart: initDate,
            numberDay: numberDay, 
            onChangeDate: onChangeDate
          ),
          ...List.generate(
            numberDay, 
            (index) => TimelineList(numberDay: index +1)
          )
        ],
      ),
    );
  }
}
