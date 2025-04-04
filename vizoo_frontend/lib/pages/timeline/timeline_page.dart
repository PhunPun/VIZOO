import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vizoo_frontend/pages/timeline/widgets/timeline_body.dart';


class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

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
        body: SizedBox.expand(
          child: Column(
            children: [
              const SizedBox(height: 70,),
              TimelineBody(
                address: 'Hà Giang',
                imageUrl: 'https://i.pinimg.com/474x/e1/24/b1/e124b1393750f24c6356e560e59ca83c.jpg',
                dayNum: '3 ngày 2 đêm',
                activitiesNum: 12,
                mealNum: 8,
                peopleNum: 3,
                residence: 'Homestay Thổ Cẩm',
                cost: 1800000,
                rating: 4,
              )
            ],
          ),
        ),
      ),
    );
  }
}