
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import '../../../models/activities.dart';

class ActList extends StatefulWidget {
  final String diaDiemId;
  final String categories;

  const ActList({
    super.key,
    required this.diaDiemId,
    required this.categories,
  });

  @override
  State<ActList> createState() => _ActListState();
}

class _ActListState extends State<ActList> {

  String? selectedActName;
  late Future<List<Activity>> _activityFuture;

  @override
  void initState() {
    super.initState();
    _activityFuture = fetchActivities();
  }

  @override
  void didUpdateWidget(covariant ActList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categories != oldWidget.categories) {
      setState(() {
        _activityFuture = fetchActivities();
      });
    }
  }

  Future<List<Activity>> fetchActivities() async {
    final snap = await FirebaseFirestore.instance
        .collection('dia_diem')
        .doc(widget.diaDiemId)
        .collection('activities')
        .where('categories', isEqualTo: widget.categories)
        .get();

    return snap.docs
        .map((doc) => Activity.fromFirestore(doc.data()!))
        .toList();
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
    final isSelected = selectedActName == act.name;
    return InkWell(
      onTap: () => setState(() => selectedActName = act.name),
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

