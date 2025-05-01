import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vizoo_frontend/pages/admin/admin_edit_timeline/widgets/admin_act_list.dart';
import 'package:vizoo_frontend/pages/admin/admin_edit_timeline/widgets/admin_set_activities.dart';
import 'package:vizoo_frontend/pages/admin/calculator/admin_set_time.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class AdminEditTimelinePage extends StatefulWidget {
  final TimeOfDay time;
  final String activities;
  final String address;
  final int price;
  final bool completed;
  final String categories;
  final String diaDiemId;
  final String tripId;
  final String timelineId;
  final String scheduleId;
  final String actId;
  final VoidCallback onRefreshTripData;

  const AdminEditTimelinePage({
    super.key,
    required this.time,
    required this.activities,
    required this.address,
    required this.price,
    required this.completed,
    required this.categories,
    required this.diaDiemId,
    required this.tripId,
    required this.timelineId,
    required this.scheduleId,
    required this.actId,
    required this.onRefreshTripData,
  });

  @override
  State<AdminEditTimelinePage> createState() => _AdminEditTimelinePageState();
}

class _AdminEditTimelinePageState extends State<AdminEditTimelinePage> {
  late String actCategories;
  late bool isCompleted;

  @override
  void initState() {
    super.initState();
    actCategories = widget.categories;
    isCompleted = widget.completed;
  }

  void onChangeCategories(String newCategories) {
    setState(() => actCategories = newCategories);
  }

  Future<void> _toggleCompleted() async {
    final newStatus = !isCompleted;
    final docRef = FirebaseFirestore.instance
        .collection('dia_diem')
        .doc(widget.diaDiemId)
        .collection('trips')
        .doc(widget.tripId)
        .collection('timelines')
        .doc(widget.timelineId)
        .collection('schedule')
        .doc(widget.scheduleId);

    await docRef.update({'status': newStatus});
    setState(() => isCompleted = newStatus);
    await _updateTripSummary(); // cập nhật sau khi đánh dấu
    widget.onRefreshTripData();
  }

  Future<void> _deleteSchedule() async {
    final scheduleRef = FirebaseFirestore.instance
        .collection('dia_diem')
        .doc(widget.diaDiemId)
        .collection('trips')
        .doc(widget.tripId)
        .collection('timelines')
        .doc(widget.timelineId)
        .collection('schedule')
        .doc(widget.scheduleId);

    await scheduleRef.delete();
    await _updateTripSummary(); // 👈 cập nhật lại thông tin tổng
    widget.onRefreshTripData();
  }

  Future<void> _updateTripSummary() async {
    int soAct = 0;
    int soEat = 0;
    int tongChiPhi = 0;
    String? noiO;

    final timelinesSnap = await FirebaseFirestore.instance
        .collection('dia_diem')
        .doc(widget.diaDiemId)
        .collection('trips')
        .doc(widget.tripId)
        .collection('timelines')
        .get();

    for (final timeline in timelinesSnap.docs) {
      final scheduleSnap = await timeline.reference.collection('schedule').get();

      for (final schedule in scheduleSnap.docs) {
        final actId = schedule['act_id'];
        if (actId == null || actId.toString().isEmpty) continue;

        soAct++;

        final actSnap = await FirebaseFirestore.instance
            .collection('dia_diem')
            .doc(widget.diaDiemId)
            .collection('activities')
            .doc(actId)
            .get();

        final actData = actSnap.data();
        if (actData == null) continue;

        final category = actData['categories'] ?? '';
        final price = (actData['price'] as num?)?.toInt() ?? 0;
        final name = actData['name'] ?? '';

        if (category == 'eat') soEat++;
        if (category == 'hotel') noiO = name;
        tongChiPhi += price;
      }
    }

    await FirebaseFirestore.instance
        .collection('dia_diem')
        .doc(widget.diaDiemId)
        .collection('trips')
        .doc(widget.tripId)
        .update({
      'so_act': soAct,
      'so_eat': soEat,
      'chi_phi': tongChiPhi,
      'noi_o': noiO ?? 'chưa chọn',
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
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              AdminSetTime(
                diaDiemId: widget.diaDiemId,
                tripId: widget.tripId,
                timelineId: widget.timelineId,
                scheduleId: widget.scheduleId,
              ),
              AdminSetActivities(
                actCategories: actCategories,
                onChangeCategories: onChangeCategories,
              ),
              AdminActList(
                diaDiemId: widget.diaDiemId,
                tripId: widget.tripId,
                timelineId: widget.timelineId,
                scheduleId: widget.scheduleId,
                categories: actCategories,
                selectedActId: widget.actId,
                onRefreshTripData: widget.onRefreshTripData,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(color: Colors.red),
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text("Xoá lịch trình này"),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Xác nhận xoá"),
                        content: const Text("Bạn có chắc muốn xoá lịch trình này không?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Huỷ"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Xoá", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _deleteSchedule();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xoá lịch trình')),
                        );
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
