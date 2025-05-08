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
  double _averageRating = 0.0;
  StreamSubscription? _loveSubscription;
  StreamSubscription? _reviewSubscription;
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
    _listenToReviews();
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

  void _listenToReviews() {
    _reviewSubscription = FirebaseFirestore.instance
        .collection('reviews')
        .where('trip_id', isEqualTo: widget.trip.id)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        // Mặc định nếu không có đánh giá thì rating = 0
        double sum = 0;
        int count = 0;
        
        if (snapshot.docs.isNotEmpty) {
          for (var doc in snapshot.docs) {
            // Lấy giá trị votes từ document
            final votes = doc.data()['votes'];
            if (votes != null && votes is num) {
              sum += votes.toDouble();
              count++;
            }
          }
        }
        
        setState(() {
          _averageRating = count > 0 ? sum / count : 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _loveSubscription?.cancel();
    _reviewSubscription?.cancel();
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

  // Hiển thị sao dựa trên rating
  Widget _buildRatingStars(double rating) {
    // Nếu chưa có đánh giá nào (rating = 0)
    if (rating <= 0) {
      return Text(
        'Chưa có đánh giá',
        style: TextStyle(
          color: Color(MyColor.pr5),
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    
    // Làm tròn xuống 0.5 gần nhất
    double roundedRating = (rating * 2).round() / 2;
    
    return Row(
      children: [
        Icon(
          roundedRating >= 1 ? Icons.star : roundedRating >= 0.5 ? Icons.star_half : Icons.star_border,
          color: Colors.amber,
          size: 18,
        ),
        Icon(
          roundedRating >= 2 ? Icons.star : roundedRating >= 1.5 ? Icons.star_half : Icons.star_border,
          color: Colors.amber,
          size: 18,
        ),
        Icon(
          roundedRating >= 3 ? Icons.star : roundedRating >= 2.5 ? Icons.star_half : Icons.star_border,
          color: Colors.amber,
          size: 18,
        ),
        Icon(
          roundedRating >= 4 ? Icons.star : roundedRating >= 3.5 ? Icons.star_half : Icons.star_border,
          color: Colors.amber,
          size: 18,
        ),
        Icon(
          roundedRating >= 5 ? Icons.star : roundedRating >= 4.5 ? Icons.star_half : Icons.star_border,
          color: Colors.amber,
          size: 18,
        ),
        SizedBox(width: 4),
        Text(
          '${roundedRating.toStringAsFixed(1)}',
          style: TextStyle(
            color: Color(MyColor.pr5),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
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
              // Nút yêu thích với số lượt thích ở chính giữa
              Positioned(
                right: 8,
                bottom: 8,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Biểu tượng trái tim không có background
                    IconButton(
                      onPressed: _handleLovePressed,
                      icon: Icon(
                        Icons.favorite,
                        color: _loved ? Color(MyColor.red) : Color(MyColor.white),
                        shadows: [
                          Shadow(
                            color: Color(MyColor.black),
                            blurRadius: 4.0,
                            offset: const Offset(0, 0.5),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.zero,
                      iconSize: 30,
                    ),
                    // Số lượt thích ở chính giữa biểu tượng trái tim
                    Container(
                      padding: EdgeInsets.all(3),
                      child: Text(
                        '$_loveCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 2.0,
                              offset: const Offset(0.5, 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                    _buildInfo("Hoạt động", widget.trip.soAct),
                    _buildInfo("Bữa ăn", widget.trip.soEat),
                    _buildInfo("Số người", widget.trip.soNguoi),
                  ],
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfo("Nơi ở", widget.trip.noiO, isText: true),
                    //_buildInfo("Số ngày", widget.trip.soNgay),
                    _buildInfo("Chi phí",
                        "${NumberFormat('#,###', 'vi_VN').format(widget.trip.chiPhi)}đ",
                        isText: true),
                    // Hiển thị rating stars
                    _buildRatingStars(_averageRating),
                    // Không cần hiển thị số lượt yêu thích ở đây vì đã hiển thị ở trên hình ảnh
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