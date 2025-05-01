import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:vizoo_frontend/models/activities.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class AdminActList extends StatefulWidget {
  final String diaDiemId;
  final String tripId;
  final String timelineId;
  final String scheduleId;
  final String categories;
  final String selectedActId;
  final VoidCallback onRefreshTripData; // ✅ thêm callback

  const AdminActList({
    super.key,
    required this.diaDiemId,
    required this.tripId,
    required this.timelineId,
    required this.scheduleId,
    required this.categories,
    required this.selectedActId,
    required this.onRefreshTripData, // ✅ thêm vào constructor
  });

  @override
  State<AdminActList> createState() => _AdminActListState();
}

class _AdminActListState extends State<AdminActList> {
  late Future<List<Activity>> _activityFuture;
  late String selectedActId;

  @override
  void initState() {
    super.initState();
    selectedActId = widget.selectedActId;
    _activityFuture = fetchActivities();
  }

  @override
  void didUpdateWidget(covariant AdminActList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categories != oldWidget.categories) {
      setState(() {
        _activityFuture = fetchActivities();
      });
    }
  }

  Future<List<Activity>> fetchActivities() async {
    final category = widget.categories.isEmpty ? 'eat' : widget.categories;

    final snap = await FirebaseFirestore.instance
        .collection('dia_diem')
        .doc(widget.diaDiemId)
        .collection('activities')
        .where('categories', isEqualTo: category)
        .get();

    return snap.docs
        .map((doc) => Activity.fromFirestore(doc.data(), id: doc.id))
        .toList();
  }

  Future<void> updateTripSummary({
    required String diaDiemId,
    required String tripId,
  }) async {
    int soAct = 0;
    int soEat = 0;
    int tongChiPhi = 0;
    String? noiO;

    final timelinesSnap = await FirebaseFirestore.instance
        .collection('dia_diem')
        .doc(diaDiemId)
        .collection('trips')
        .doc(tripId)
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
            .doc(diaDiemId)
            .collection('activities')
            .doc(actId)
            .get();

        final actData = actSnap.data();
        if (actData == null) continue;

        final categories = actData['categories'] ?? '';
        final price = (actData['price'] as num?)?.toInt() ?? 0;
        final name = actData['name'] ?? '';

        if (categories == 'eat') soEat++;
        if (categories == 'hotel') noiO = name;
        tongChiPhi += price;
      }
    }

    await FirebaseFirestore.instance
        .collection('dia_diem')
        .doc(diaDiemId)
        .collection('trips')
        .doc(tripId)
        .update({
      'so_act': soAct,
      'so_eat': soEat,
      'chi_phi': tongChiPhi,
      'noi_o': noiO ?? 'chưa chọn',
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Activity>>(
      future: _activityFuture,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final acts = snap.data ?? [];
        if (acts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Không có hoạt động cho danh mục này',
              style: TextStyle(color: Color(MyColor.grey)),
            ),
          );
        }
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
          padding: const EdgeInsets.only(top: 13, left: 8, right: 8, bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(MyColor.pr5)),
          ),
          child: Column(
            children: acts.map((act) => _actCard(act)).toList(),
          ),
        );
      },
    );
  }

  Widget _actCard(Activity act) {
    final isSelected = act.id == selectedActId;

    return InkWell(
      onTap: () async {
        setState(() => selectedActId = act.id);

        final scheduleRef = FirebaseFirestore.instance
            .collection('dia_diem')
            .doc(widget.diaDiemId)
            .collection('trips')
            .doc(widget.tripId)
            .collection('timelines')
            .doc(widget.timelineId)
            .collection('schedule')
            .doc(widget.scheduleId);

        await scheduleRef.update({'act_id': act.id});

        await updateTripSummary(
          diaDiemId: widget.diaDiemId,
          tripId: widget.tripId,
        );

        widget.onRefreshTripData(); // ✅ gọi để ép cập nhật UI
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(width: 4, color: Color(MyColor.pr3)),
            bottom: BorderSide(width: 0.2, color: Color(MyColor.pr3)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    act.name,
                    style: const TextStyle(
                      color: Color(MyColor.black),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    act.address,
                    style: const TextStyle(
                      color: Color(MyColor.grey),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "${NumberFormat('#,###', 'vi_VN').format(act.price)}đ",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(MyColor.pr4),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: isSelected
                    ? SvgPicture.asset(
                        'assets/icons/done.svg',
                        width: 13.33,
                        height: 13.33,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
