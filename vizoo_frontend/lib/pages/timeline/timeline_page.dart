import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vizoo_frontend/pages/timeline/widgets/timeline_body.dart';

import '../../themes/colors/colors.dart';

class TimelinePage extends StatelessWidget {
  final String tripId;
  final String locationId;

  const TimelinePage({
    super.key,
    required this.tripId,
    required this.locationId,
  });

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
                tripId: tripId,
                locationId: locationId,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
