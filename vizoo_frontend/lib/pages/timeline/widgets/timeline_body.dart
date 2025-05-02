import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/widgets/set_day_start.dart';
import 'package:vizoo_frontend/widgets/set_people_num.dart';
import 'package:vizoo_frontend/pages/timeline/widgets/timeline_list.dart';
import 'package:vizoo_frontend/widgets/trip_card.dart';
import 'package:vizoo_frontend/models/trip_models_json.dart';

class TimelineBody extends StatefulWidget {
  final String tripId;
  final String locationId;
  final VoidCallback? onDataChanged; // ✅ THÊM

  const TimelineBody({
    super.key,
    required this.tripId,
    required this.locationId,
    this.onDataChanged,
  });

  @override
  State<TimelineBody> createState() => _TimelineBodyState();
}

class _TimelineBodyState extends State<TimelineBody> {
  Trip? tripData;
  DateTime initDate = DateTime.now();
  List<int> days = [];

  late final DocumentReference<Map<String, dynamic>> _masterTripRef;
  DocumentReference<Map<String, dynamic>>? _userTripRef;
  bool _useUserData = false;

  @override
  void initState() {
    super.initState();

    _masterTripRef = FirebaseFirestore.instance
        .collection('dia_diem')
        .doc(widget.locationId)
        .collection('trips')
        .doc(widget.tripId);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userTripRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('selected_trips')
          .doc(widget.tripId);
    }

    _loadTripData().then((_) {
      _fetchDayNumbers();
      _loadTripDetails();
    });
  }

  Future<void> _loadTripData() async {
    try {
      if (_userTripRef != null) {
        final snapUser = await _userTripRef!.get();
        if (snapUser.exists) {
          if (!mounted) return;
          setState(() {
            _useUserData = true;
            tripData = Trip.fromJson(
              snapUser.data()!,
              id: widget.tripId,
              locationId: widget.locationId,
            );
            initDate = tripData!.ngayBatDau;
          });
          return;
        }
      }

      final snapMaster = await _masterTripRef.get();
      if (snapMaster.exists) {
        if (!mounted) return;
        setState(() {
          tripData = Trip.fromJson(
            snapMaster.data()!,
            id: widget.tripId,
            locationId: widget.locationId,
          );
          initDate = tripData!.ngayBatDau;
        });
      }
    } catch (e) {
      print('Lỗi khi lấy dữ liệu chuyến đi: $e');
    }
  }

  Future<void> _fetchDayNumbers() async {
    try {
      final baseRef = (_useUserData && _userTripRef != null)
          ? _userTripRef!
          : _masterTripRef;

      final snap = await baseRef
          .collection('timelines')
          .orderBy('day_number')
          .get();

      final fetchedDays = snap.docs
          .map((d) => (d.data()['day_number'] as int))
          .toList();

      if (!mounted) return;
      setState(() {
        days = fetchedDays;
      });
    } catch (e) {
      print('Lỗi khi lấy dữ liệu ngày: $e');
    }
  }

  // ✅ Tải lại dữ liệu cho TripCard
  Future<void> _loadTripDetails() async {
    await Future.wait([
      _loadActivityCount(),
      _loadMealCount(),
      _loadTotalCost(),
    ]);
  }

  Future<void> _loadActivityCount() async {
    int count = 0;
    final timelines = await _baseTripRef.collection('timelines').get();
    for (var tl in timelines.docs) {
      final sch = await tl.reference.collection('schedule').get();
      count += sch.docs.length;
    }
    if (!mounted) return;
    setState(() => tripData = tripData?.copyWith(soAct: count));
  }

  Future<void> _loadMealCount() async {
    int count = 0;
    final timelines = await _baseTripRef.collection('timelines').get();
    for (var tl in timelines.docs) {
      final sch = await tl.reference.collection('schedule').get();
      for (var doc in sch.docs) {
        final actId = doc.data()['act_id'] as String?;
        if (actId == null) continue;
        final actDoc = await FirebaseFirestore.instance
            .collection('dia_diem')
            .doc(widget.locationId)
            .collection('activities')
            .doc(actId)
            .get();
        if (actDoc.exists && actDoc.data()?['categories'] == 'eat') {
          count++;
        }
      }
    }
    if (!mounted) return;
    setState(() => tripData = tripData?.copyWith(soEat: count));
  }

  Future<void> _loadTotalCost() async {
    double sum = 0;
    final timelines = await _baseTripRef.collection('timelines').get();
    for (var tl in timelines.docs) {
      final sch = await tl.reference.collection('schedule').get();
      for (var doc in sch.docs) {
        final actId = doc.data()['act_id'] as String?;
        if (actId == null) continue;
        final actDoc = await FirebaseFirestore.instance
            .collection('dia_diem')
            .doc(widget.locationId)
            .collection('activities')
            .doc(actId)
            .get();
        if (actDoc.exists) {
          sum += (actDoc.data()?['price'] ?? 0).toDouble();
        }
      }
    }
    if (!mounted) return;
    setState(() => tripData = tripData?.copyWith(chiPhi: sum.toInt()));
  }

  void onSetPeople(int newCount) {
    if (tripData != null) {
      setState(() {
        tripData = tripData!.copyWith(soNguoi: newCount);
      });
    }
  }

  void onChangeDate(DateTime newDate) {
    setState(() {
      initDate = newDate;
    });
  }

  DocumentReference<Map<String, dynamic>> get _baseTripRef =>
      (_useUserData && _userTripRef != null) ? _userTripRef! : _masterTripRef;

  @override
  Widget build(BuildContext context) {
    if (tripData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TripCard(trip: tripData!),
          SetPeopleNum(
            peopleNum: tripData!.soNguoi,
            cost: tripData!.chiPhi,
            onSetPeople: onSetPeople,
            onSetCost: (_) => _loadTripDetails(),
            diaDiemId: widget.locationId,
            tripId: widget.tripId,
          ),
          SetDayStart(
            dateStart: initDate,
            numberDay: tripData!.soNgay,
            onChangeDate: onChangeDate,
            locationId: widget.locationId,
            tripId: widget.tripId,
          ),
          const SizedBox(height: 16),
          if (days.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Không có lịch trình cho ngày nào'),
            )
          else
            ...days.map((day) {
              final query = _baseTripRef
                  .collection('timelines')
                  .where('day_number', isEqualTo: day);

              return TimelineList(
                numberDay: day,
                timelineQuery: query,
                locationId: widget.locationId,
                tripId: widget.tripId,
                onDataChanged: () async {
                  await _loadTripData();
                  await _fetchDayNumbers();
                  await _loadTripDetails(); // ✅ cập nhật lại TripCard
                  widget.onDataChanged?.call();
                },
              );
            }).toList(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
