import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vizoo_frontend/pages/admin/admin_timeline/widgets/admin_timeline_body.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class AdminTimelinePage extends StatefulWidget {
  final String tripId;
  final String locationId;

  const AdminTimelinePage({
    super.key,
    required this.tripId,
    required this.locationId,
  });

  @override
  State<AdminTimelinePage> createState() => _AdminTimelinePageState();
}

class _AdminTimelinePageState extends State<AdminTimelinePage> {
  Key _refreshKey = UniqueKey(); // ✅ tạo key để ép rebuild

  void _handleRefreshTripData() {
    setState(() {
      _refreshKey = UniqueKey(); // ✅ đổi key để ép vẽ lại AdminTimelineBody
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(MyColor.white),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: IconButton(
            icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 5),
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
              const SizedBox(height: 70),
              AdminTimelineBody(
                key: _refreshKey, // ✅ quan trọng để ép vẽ lại widget
                tripId: widget.tripId,
                locationId: widget.locationId,
                onRefreshTripData: _handleRefreshTripData, // ✅ truyền callback
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
