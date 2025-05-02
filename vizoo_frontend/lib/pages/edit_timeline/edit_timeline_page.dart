import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final String tripId;
  final String timelineId;
  final String scheduleId;

  const EditTimelinePage({
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
  });

  @override
  State<EditTimelinePage> createState() => _EditTimelinePageState();
}

class _EditTimelinePageState extends State<EditTimelinePage> {
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

  /// Đảm bảo chuyến đã được clone vào users/{uid}/selected_trips
  Future<void> _ensureUserTripExists() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;
    final userTripRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('selected_trips')
        .doc(widget.tripId);

    final userTripSnap = await userTripRef.get();
    if (userTripSnap.exists) return;

    // Clone data chuyến gốc
    final origTripRef = FirebaseFirestore.instance
        .collection('dia_diem')
        .doc(widget.diaDiemId)
        .collection('trips')
        .doc(widget.tripId);
    final origTripSnap = await origTripRef.get();
    if (!origTripSnap.exists) return;

    await userTripRef.set(origTripSnap.data()!);

    // Clone timelines và schedule
    final timelinesSnap = await origTripRef.collection('timelines').get();
    for (final tlDoc in timelinesSnap.docs) {
      final userTlRef = userTripRef.collection('timelines').doc(tlDoc.id);
      await userTlRef.set(tlDoc.data());
      final scheduleSnap = await origTripRef
          .collection('timelines')
          .doc(tlDoc.id)
          .collection('schedule')
          .get();
      for (final scDoc in scheduleSnap.docs) {
        final userScRef = userTlRef.collection('schedule').doc(scDoc.id);
        await userScRef.set(scDoc.data()!);
      }
    }
  }
  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa hoạt động này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<void> _toggleCompleted() async {
    final newStatus = !isCompleted;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;

    //  clone chuyến
    await _ensureUserTripExists();
    // Cập nhật status vào user
    final scheduleRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('selected_trips')
        .doc(widget.tripId)
        .collection('timelines')
        .doc(widget.timelineId)
        .collection('schedule')
        .doc(widget.scheduleId);

    await scheduleRef.update({'status': newStatus});
    setState(() => isCompleted = newStatus);
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
            onPressed: () => Navigator.of(context).pop(true),
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
              // Widget chọn thời gian
              SetTime(
                diaDiemId: widget.diaDiemId,
                tripId: widget.tripId,
                timelineId: widget.timelineId,
                scheduleId: widget.scheduleId,
              ),

              // Widget chọn danh mục hoạt động
              SetActivities(
                actCategories: actCategories,
                onChangeCategories: onChangeCategories,
              ),

              // Danh sách hoạt động (lọc theo danh mục)
              ActList(
                diaDiemId: widget.diaDiemId,
                categories: actCategories,
                tripId: widget.tripId,
                timelineId: widget.timelineId,
                scheduleId: widget.scheduleId,
              ),

              // Nút đánh dấu hoàn thành
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      child: InkWell(
                        onTap: () async {
                          try {
                            await _toggleCompleted();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isCompleted
                                      ? 'Đã đánh dấu hoàn thành'
                                      : 'Bỏ đánh dấu hoàn thành',
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi: $e')),
                            );
                          }
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                            color: isCompleted ? Color(MyColor.pr2) : Colors.transparent,
                          ),
                          child: isCompleted
                              ? const Icon(Icons.check, color: Color(MyColor.pr5), size: 16)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Nút xóa hoạt động
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final confirm = await showDeleteConfirmationDialog(context);
                    if (!confirm) return;

                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;
                    final uid = user.uid;

                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('selected_trips')
                          .doc(widget.tripId)
                          .collection('timelines')
                          .doc(widget.timelineId)
                          .collection('schedule')
                          .doc(widget.scheduleId)
                          .delete();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã xóa hoạt động.')),
                      );

                      Navigator.of(context).pop(true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi khi xóa: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Xóa hoạt động'),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

