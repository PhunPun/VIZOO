import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class SetTime extends StatefulWidget {
  final String diaDiemId;
  final String tripId;
  final String timelineId;
  final String scheduleId;

  const SetTime({
    super.key,
    required this.diaDiemId,
    required this.tripId,
    required this.timelineId,
    required this.scheduleId,
  });

  @override
  State<SetTime> createState() => _SetTimeState();
}


class _SetTimeState extends State<SetTime> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 21, minute: 0);

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _ensureUserTripExists();
    await _loadInitialTimeFromFirestore();
  }

  /// Nếu chưa có chuyến trong users
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

    // Lấy dữ liệu chuyến gốc
    final origTripRef = FirebaseFirestore.instance
        .collection('dia_diem')
        .doc(widget.diaDiemId)
        .collection('trips')
        .doc(widget.tripId);
    final origTripSnap = await origTripRef.get();
    if (!origTripSnap.exists) return;

    // Clone dữ liệu chuyến lên users
    await userTripRef.set({
      ...origTripSnap.data()!,
      'location_id': widget.diaDiemId,
    });
    // Clone timelines và schedule
    final timelinesSnap = await origTripRef.collection('timelines').get();
    for (final tlDoc in timelinesSnap.docs) {
      final userTlRef = userTripRef.collection('timelines').doc(tlDoc.id);
      await userTlRef.set({
        ...tlDoc.data(),
        'location_id': widget.diaDiemId,
      });

      final scheduleSnap = await origTripRef
          .collection('timelines')
          .doc(tlDoc.id)
          .collection('schedule')
          .get();
      for (final scDoc in scheduleSnap.docs) {
        final userScRef = userTlRef.collection('schedule').doc(scDoc.id);
        await userScRef.set({
          ...scDoc.data(),
          'location_id': widget.diaDiemId,
        });
      }
    }
  }
    Future<void> _loadInitialTimeFromFirestore() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final uid = user.uid;

      final scheduleRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('selected_trips')
          .doc(widget.tripId)
          .collection('timelines')
          .doc(widget.timelineId)
          .collection('schedule')
          .doc(widget.scheduleId);

      try {
        final snap = await scheduleRef.get();
        if (snap.exists && snap.data()!.containsKey('hour')) {
          _applyHourString(snap.data()!['hour'] as String);
        }
      } catch (e) {
        debugPrint('Lỗi load time user: \$e');
      }
    }

    void _applyHourString(String hourStr) {
      final parts = hourStr.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? _selectedTime.hour;
        final minute = int.tryParse(parts[1]) ?? _selectedTime.minute;
        setState(() {
          _selectedTime = TimeOfDay(hour: hour, minute: minute);
        });
      }
    }
    String _formatTime(TimeOfDay t) => t.hour.toString().padLeft(2, '0') + ':' + t.minute.toString().padLeft(2, '0');
  Future<void> _updateTimeInFirestore(TimeOfDay selectedTime) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;
    final hourFormatted = selectedTime.hour.toString().padLeft(2, '0') + ':' + selectedTime.minute.toString().padLeft(2, '0');

    final scheduleRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('selected_trips')
        .doc(widget.tripId)
        .collection('timelines')
        .doc(widget.timelineId)
        .collection('schedule')
        .doc(widget.scheduleId);

    await scheduleRef.set({
      'hour': hourFormatted,
      'location_id': widget.diaDiemId,
    }, SetOptions(merge: true));
  }

    Future<void> _showTimePickerDialog(BuildContext context) async {
    final int initialHour = _selectedTime.hour;
    final int initialMinute = _selectedTime.minute;
    int tempHour = _selectedTime.hour;
    int tempMinute = _selectedTime.minute;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Chọn thời gian',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Thanh trượt chọn giờ
                Expanded(
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setDialogState) {
                      return ListWheelScrollView.useDelegate(
                        itemExtent: 50,
                        perspective: 0.005,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setDialogState(() {
                            tempHour = index;
                          });
                          setState(() {
                            _selectedTime = TimeOfDay(
                              hour: tempHour,
                              minute: tempMinute,
                            );
                          });
                        },
                        childDelegate: ListWheelChildLoopingListDelegate(
                          children: List<Widget>.generate(24, (index) {
                            return Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 24,
                                  color: index == tempHour && index == initialHour
                                      ? const Color(MyColor.pr5) 
                                      : index == tempHour
                                      ? const Color(MyColor.pr4)
                                        : index == initialHour
                                            ? const Color(MyColor.pr5) 
                                            : Colors.grey, 
                                  fontWeight: index == tempHour
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          }),
                        ),
                        controller: FixedExtentScrollController(
                          initialItem: _selectedTime.hour,
                        ),
                      );
                    },
                  ),
                ),
                // Dấu hai chấm
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    ':',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                // Thanh trượt chọn phút
                Expanded(
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setDialogState) {
                      return ListWheelScrollView.useDelegate(
                        itemExtent: 50,
                        perspective: 0.005,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setDialogState(() {
                            tempMinute = index;
                          });
                          setState(() {
                            _selectedTime = TimeOfDay(
                              hour: tempHour,
                              minute: tempMinute,
                            );
                          });
                        },
                        childDelegate: ListWheelChildLoopingListDelegate(
                          children: List<Widget>.generate(60, (index) {
                            return Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 24,
                                  color: index == tempMinute && index == initialMinute
                                      ? const Color(MyColor.pr5) 
                                      : index == tempMinute
                                      ? const Color(MyColor.pr4)
                                        : index == initialMinute
                                            ? const Color(MyColor.pr5) 
                                            : Colors.grey, 
                                  fontWeight: index == tempMinute
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          }),
                        ),
                        controller: FixedExtentScrollController(
                          initialItem: _selectedTime.minute,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedTime = TimeOfDay(
                    hour: initialHour,
                    minute: initialMinute,
                  ); 
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                'Hủy',
                style: TextStyle(
                  color: Color(MyColor.pr5)
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final newTime = TimeOfDay(hour: tempHour, minute: tempMinute);
                await _updateTimeInFirestore(newTime);
                setState(() { _selectedTime = newTime; });
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(MyColor.pr5)
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 100),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(MyColor.pr3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/icons/time.svg'),
                        const SizedBox(width: 8),
                        const Text(
                          'Thời gian',
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
                        onTap: () => _showTimePickerDialog(context), 
                        child: Text(_formatTime(_selectedTime),
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
            ],
          ),
        ),
      ],
    );
  }
}