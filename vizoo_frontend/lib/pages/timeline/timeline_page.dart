import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vizoo_frontend/pages/timeline/widgets/timeline_body.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';


class TimelinePage extends StatefulWidget {
  final String address; // dia diem
  final String imageUrl; //
  final String dayNum; // so ngay
  final int activitiesNum; // so hoat dong
  final int mealNum; // so bua an
  final int peopleNum; // so nguoi
  final String residence; // noi o
  final int cost; // chi phi
  final int rating; // danh gia
  const TimelinePage({
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
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Icon đen
      ),
      child: Scaffold(
        backgroundColor: Color(MyColor.white),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: IconButton(
            icon: Icon(
              Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 5),
              child: SvgPicture.asset(
                'assets/icons/logo.svg',
                width: 98.79,
                height: 28.26,
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 70,),
              TimelineBody(
                address: widget.address, 
                imageUrl: widget.imageUrl, 
                dayNum: widget.dayNum, 
                activitiesNum: widget.activitiesNum, 
                mealNum: widget.mealNum, 
                peopleNum: widget.peopleNum, 
                residence: widget.residence, 
                cost: widget.cost, 
                rating: widget.rating)
            ],
          ),
        ),
      ),
    );
  }
}