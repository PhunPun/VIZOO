import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:vizoo_frontend/pages/home/home_page.dart';
import 'package:vizoo_frontend/pages/timeline/timeline_page.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/widgets/weather_card.dart';

class SetDayStart extends StatefulWidget {
  final DateTime dateStart;
  final int numberDay;
  final ValueChanged<DateTime> onChangeDate;
  final String locationId;
  final String tripId;
  final String? se_tripId;

  const SetDayStart({
    super.key,
    required this.dateStart,
    required this.numberDay,
    required this.onChangeDate,
    required this.locationId,
    required this.tripId,
    this.se_tripId,
  });

  @override
  State<SetDayStart> createState() => _SetDayStartState();
}

class _SetDayStartState extends State<SetDayStart> {
  late DateTime _selectedDate;
  String se_tripId = "";
  DocumentReference<Map<String, dynamic>>? _userTripRef;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.dateStart;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // nếu có sẵn tripId thì dùng luôn, không thì tạo mới
      if (widget.se_tripId != null) {
        _userTripRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('selected_trips')
            .doc(widget.se_tripId);
      } else {
        final newDoc =
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('selected_trips')
                .doc();
        _userTripRef = newDoc;
      }

      // nếu đã có _userTripRef thì lấy id và gọi load
      if (_userTripRef != null) {
        se_tripId = _userTripRef!.id;
        _loadStartDate();
      }
    }
  }

  Future<void> _loadStartDate() async {
    if (_userTripRef == null) return;
    try {
      final snap = await _userTripRef!.get();
      final data = snap.data();
      if (data != null && data.containsKey('ngay_bat_dau')) {
        setState(() {
          _selectedDate = (data['ngay_bat_dau'] as Timestamp).toDate();
        });
        widget.onChangeDate(_selectedDate);
      }
    } catch (e) {
      debugPrint('Lỗi khi load ngày bắt đầu: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder:
          (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: ColorScheme.light(
                primary: Color(MyColor.pr4),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              dialogTheme: DialogTheme(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            child: child!,
          ),
    );

    if (picked != null && picked != _selectedDate) {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      if (picked.isBefore(today)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể chọn ngày trong quá khứ!')),
        );
        return;
      }

      setState(() {
        _selectedDate = picked;
      });
      widget.onChangeDate(_selectedDate);
      await _updateFirestore(_selectedDate);
    }
  }

  Future<void> _updateFirestore(DateTime newDate) async {
    if (_userTripRef == null) return;
    try {
      final snap = await _userTripRef!.get();
      if (!snap.exists) {
        // copy toàn bộ lần đầu
        final masterRef = FirebaseFirestore.instance
            .collection('dia_diem')
            .doc(widget.locationId)
            .collection('trips')
            .doc(widget.tripId);
        final masterSnap = await masterRef.get();
        if (masterSnap.exists) {
          await _userTripRef!.set({
            ...masterSnap.data()!,
            'saved_at': FieldValue.serverTimestamp(),
            'location_id': widget.locationId,
          }, SetOptions(merge: true));

          // copy timelines + schedule
          final tlSnap = await masterRef.collection('timelines').get();
          for (var tl in tlSnap.docs) {
            await _userTripRef!.collection('timelines').doc(tl.id).set({
              ...tl.data(),
              'location_id': widget.locationId,
            }, SetOptions(merge: true));
            final schSnap = await tl.reference.collection('schedule').get();
            for (var sch in schSnap.docs) {
              await _userTripRef!
                  .collection('timelines')
                  .doc(tl.id)
                  .collection('schedule')
                  .doc(sch.id)
                  .set({
                    ...sch.data(),
                    'location_id': widget.locationId,
                  }, SetOptions(merge: true));
            }
          }
        }
      }
      // cập nhật ngày mới
      await _userTripRef!.update({
        'ngay_bat_dau': Timestamp.fromDate(newDate),
        'location_id': widget.locationId,
      });
      if (widget.se_tripId == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomePage(se_tripId: se_tripId)),
        );
      }
    } catch (e) {
      debugPrint('Lỗi khi lưu hoặc cập nhật trip: \$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(MyColor.pr3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    SvgPicture.asset('assets/icons/schedule.svg'),
                    const SizedBox(width: 8),
                    const Text(
                      'Ngày bắt đầu',
                      style: TextStyle(
                        color: Color(MyColor.black),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      if (widget.se_tripId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Bạn cần \"Áp dụng chuyến đi\" để chỉnh sửa.',
                            ),
                          ),
                        );
                      } else {
                        _selectDate(context);
                      }
                    },
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                      style: const TextStyle(
                        color: Color(MyColor.pr4),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 2,
            margin: const EdgeInsets.only(left: 15, top: 4),
            color: const Color(MyColor.pr5),
          ),
          WeatherCard(
            diaDiemId: widget.locationId,
            tripId: widget.tripId,
            se_tripId: widget.se_tripId,
            //isFromUserTrip: true,
          ),
        ],
      ),
    );
  }
}
