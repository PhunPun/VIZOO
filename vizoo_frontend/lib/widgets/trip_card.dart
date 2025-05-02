import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vizoo_frontend/calculator/day_format.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:intl/intl.dart';
import '../models/trip_models_json.dart';

class TripCard extends StatefulWidget {
  final Trip trip;
  final VoidCallback? onTap;

  const TripCard({
    super.key,
    required this.trip,
    this.onTap,
  });

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  bool _loved = false;
  int _activityCount = 0;
  double _totalCost = 0;
  int _mealCount = 0;
  int _loveCount = 0;
  StreamSubscription? _loveSubscription;
  bool _useUserData = false;

  late DocumentReference<Map<String, dynamic>> _masterTripRef;
  DocumentReference<Map<String, dynamic>>? _userTripRef;

  DocumentReference<Map<String, dynamic>> get _baseTripRef {
    if (_useUserData && _userTripRef != null) {
      return _userTripRef!;
    }
    return _masterTripRef;
  }

  @override
void initState() {
  super.initState();

  // Kiểm tra ID hợp lệ trước khi tạo DocumentReference
  if (widget.trip.id.isEmpty || widget.trip.locationId.isEmpty) {
    print("[ERROR] trip.id hoặc locationId rỗng!");
    return;
  }

  // Luôn có _masterTripRef
  _masterTripRef = FirebaseFirestore.instance
      .collection('dia_diem')
      .doc(widget.trip.locationId)
      .collection('trips')
      .doc(widget.trip.id);

  // Nếu có user và trip.id hợp lệ thì tạo _userTripRef
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    _userTripRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('selected_trips')
        .doc(widget.trip.id);
  }

  // Gọi sau khi đảm bảo không có lỗi
  _initData();
  _checkIfLoved();
  _listenToLoveCount();
}


  Future<void> _initData() async {
  try {
    if (_userTripRef != null) {
      final snap = await _userTripRef!.get();
      if (snap.exists) {
        if (!mounted) return; // tránh lỗi gọi setState sau dispose
        setState(() => _useUserData = true);
      }
    }

    await Future.wait([
      _loadActivityCount(),
      _loadMealCount(),
      _loadTotalCost(),
    ]);
  } catch (e) {
    print('[ERROR] _initData thất bại: $e');
  }
}


  void _listenToLoveCount() {
    _loveSubscription = FirebaseFirestore.instance
        .collection('love')
        .where('trip_id', isEqualTo: widget.trip.id)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _loveCount = snapshot.docs.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _loveSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkIfLoved() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('love')
        .where('user_id', isEqualTo: currentUser.uid)
        .where('trip_id', isEqualTo: widget.trip.id)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty && mounted) {
      setState(() {
        _loved = true;
      });
    }
  }

  Future<void> _handleLovePressed() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bạn cần đăng nhập để yêu thích chuyến đi")),
      );
      return;
    }

    setState(() {
      _loved = !_loved;
    });

    final loveRef = FirebaseFirestore.instance.collection("love");

    if (_loved) {
      await loveRef.add({
        'user_id': currentUser.uid,
        'trip_id': widget.trip.id,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      final existing = await loveRef
          .where('user_id', isEqualTo: currentUser.uid)
          .where('trip_id', isEqualTo: widget.trip.id)
          .get();

      for (final doc in existing.docs) {
        await doc.reference.delete();
      }
    }
  }

  Future<void> _loadActivityCount() async {
    int count = 0;
    final timelines = await _baseTripRef.collection('timelines').get();
    for (var tl in timelines.docs) {
      final sch = await tl.reference.collection('schedule').get();
      count += sch.docs.length;
    }
    if (mounted) setState(() => _activityCount = count);
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
            .doc(widget.trip.locationId)
            .collection('activities')
            .doc(actId)
            .get();
        if (actDoc.exists && actDoc.data()?['categories'] == 'eat') {
          count += 1;
        }
      }
    }
    if (mounted) setState(() => _mealCount = count);
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
            .doc(widget.trip.locationId)
            .collection('activities')
            .doc(actId)
            .get();
        if (actDoc.exists) {
          sum += (actDoc.data()?['price'] ?? 0).toDouble();
        }
      }
    }
    if (mounted) setState(() => _totalCost = sum);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTap?.call(),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 8),
              SvgPicture.asset('assets/icons/logo_avt.svg'),
              const SizedBox(width: 8),
              Text(
                widget.trip.name + " ",
                style: TextStyle(
                    color: Color(MyColor.black),
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                dayFormat(widget.trip.soNgay),
                style: TextStyle(
                    color: Color(MyColor.black),
                    fontSize: 13,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.trip.anh),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: IconButton(
                  onPressed: _handleLovePressed,
                  icon: Icon(
                    Icons.favorite,
                    color:
                        _loved ? Color(MyColor.red) : Color(MyColor.white),
                    shadows: [
                      Shadow(
                        color: Color(MyColor.black),
                        blurRadius: 4.0,
                        offset: const Offset(0, 0.5),
                      ),
                    ],
                  ),
                  iconSize: 30,
                ),
              )
            ],
          ),
          Container(
            width: double.infinity,
            color: Color(MyColor.pr1),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfo("Hoạt động", _activityCount),
                    _buildInfo("Bữa ăn", _mealCount),
                    _buildInfo("Số người", widget.trip.soNguoi),
                  ],
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfo("Nơi ở", widget.trip.noiO, isText: true),
                    _buildInfo("Số ngày", widget.trip.soNgay),
                    _buildInfo("Chi phí",
                        "${NumberFormat('#,###', 'vi_VN').format(widget.trip.soNguoi * _totalCost)}đ",
                        isText: true),
                    Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red, size: 20),
                        SizedBox(width: 4),
                        Text(
                          '$_loveCount lượt yêu thích',
                          style: TextStyle(
                            color: Color(MyColor.pr5),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(String label, dynamic value, {bool isText = false}) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 150),
          child: Text(
            "$value",
            style: TextStyle(
              color: Color(MyColor.pr5),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            overflow: isText ? TextOverflow.ellipsis : null,
            maxLines: isText ? 1 : null,
          ),
        ),
      ],
    );
  }
}
