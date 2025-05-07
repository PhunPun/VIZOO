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
  final String actId;
  final String? se_tripId;

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
    required this.actId,
    this.se_tripId,
  });

  @override
  State<EditTimelinePage> createState() => _EditTimelinePageState();
}

class _EditTimelinePageState extends State<EditTimelinePage> {
  late String actCategories;
  late bool isCompleted;
  String? se_tripId;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    actCategories = widget.categories;
    isCompleted = widget.completed;
    _initFuture = _ensureUserTripExists();
  }

  void onChangeCategories(String newCategories) {
    setState(() => actCategories = newCategories);
  }

  Future<void> _ensureUserTripExists() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final uid = user.uid;

  if (widget.se_tripId != null) {
    // Nếu đã có se_tripId => chỉ dùng lại
    se_tripId = widget.se_tripId;
    final userTripRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('selected_trips')
        .doc(se_tripId);

    final userTripSnap = await userTripRef.get();
    if (!userTripSnap.exists) {
      debugPrint("⚠️ se_tripId được truyền nhưng không tồn tại trong Firestore.");
    }
    return;
  }

  // Nếu không có se_tripId => tạo mới selected_trips từ master
  final newTripRef = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('selected_trips')
      .doc();
  se_tripId = newTripRef.id;

  final masterTripRef = FirebaseFirestore.instance
      .collection('dia_diem')
      .doc(widget.diaDiemId)
      .collection('trips')
      .doc(widget.tripId);

  final masterSnap = await masterTripRef.get();
  if (!masterSnap.exists) return;

  await newTripRef.set(masterSnap.data()!);
  final timelinesSnap = await masterTripRef.collection('timelines').get();

  for (final tlDoc in timelinesSnap.docs) {
    final newTlRef = newTripRef.collection('timelines').doc(tlDoc.id);
    await newTlRef.set(tlDoc.data());

    final scheduleSnap = await tlDoc.reference.collection('schedule').get();
    for (final scDoc in scheduleSnap.docs) {
      await newTlRef.collection('schedule').doc(scDoc.id).set(scDoc.data());
    }
  }
}


  Future<void> _toggleCompleted() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || se_tripId == null) return;
    final newStatus = !isCompleted;

    final scheduleRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('selected_trips')
        .doc(se_tripId)
        .collection('timelines')
        .doc(widget.timelineId)
        .collection('schedule')
        .doc(widget.scheduleId);

    await scheduleRef.update({'status': newStatus});
    setState(() => isCompleted = newStatus);
    Navigator.of(context).pop(true);
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Xóa'),
              ),
            ],
          ),
        ) ??
        false;
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
        body: FutureBuilder(
          future: _initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  SetTime(
                    diaDiemId: widget.diaDiemId,
                    tripId: widget.tripId,
                    timelineId: widget.timelineId,
                    scheduleId: widget.scheduleId,
                    se_tripId: se_tripId,
                  ),
                  SetActivities(
                    actCategories: actCategories,
                    onChangeCategories: onChangeCategories,
                  ),
                  ActList(
                    diaDiemId: widget.diaDiemId,
                  tripId: widget.tripId,
                  timelineId: widget.timelineId,
                  scheduleId: widget.scheduleId,
                  categories: actCategories,
                  selectedActId: widget.actId,
                  se_tripId: se_tripId,
                  ),
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
                            onTap: _toggleCompleted,
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
                        if (user == null || se_tripId == null) return;

                        try {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('selected_trips')
                              .doc(se_tripId)
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
            );
          },
        ),
      ),
    );
  }
}
