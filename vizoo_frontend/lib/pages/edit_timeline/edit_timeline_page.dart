import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/pages/edit_timeline/widgets/act_list.dart';
import 'package:vizoo_frontend/pages/edit_timeline/widgets/set_activities.dart';
import 'package:vizoo_frontend/widgets/set_time.dart';

class EditTimelinePage extends StatefulWidget {
  final TimeOfDay time;
  final String activities;
  final String address;
  final int price;
  final bool completed;
  final String categories;
  final String diaDiemId;
  const EditTimelinePage({
    super.key,
    required this.time,
    required this.activities,
    required this.address,
    required this.price,
    required this.completed,
    required this.categories,
    required this.diaDiemId,
  });

  @override
  State<EditTimelinePage> createState() => _EditTimelinePageState();
}

class _EditTimelinePageState extends State<EditTimelinePage> {
  late String actCategories;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo từ categories truyền vào
    actCategories = widget.categories;
  }

  void onChangeCategories(String newCategories) {
    setState(() {
      actCategories = newCategories;
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
              SetTime(),
              // Truyền actCategories từ state
              SetActivities(
                actCategories: actCategories,
                onChangeCategories: onChangeCategories,
              ),
              // Truyền actCategories xuống ActList để filter
              ActList(
                diaDiemId: widget.diaDiemId,
                categories: actCategories,
              ),

              // Phần "Đánh dấu đã hoàn thành"
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1, color: Color(MyColor.pr5)),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      flex: 8,
                      child: Text(
                        'Đánh dấu đã hoàn thành',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                          color: isCompleted ? Color(MyColor.pr2) : Colors.transparent,
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isCompleted = !isCompleted;
                            });
                          },
                          child: isCompleted
                              ? const Icon(Icons.check, color: Color(MyColor.pr5), size: 16)
                              : null,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

