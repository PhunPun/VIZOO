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
    int _loveCount = 0;
    StreamSubscription? _loveSubscription;

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

    @override
    void initState() {
      super.initState();
      _checkIfLoved();
      _listenToLoveCount();
    }

    // Hàm định dạng ngày tháng
    String getFormattedDate(DateTime date) {
      return DateFormat("dd/MM/yyyy").format(date);
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

    Future<void> _checkIfLoved() async {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final loveRef = FirebaseFirestore.instance.collection('love');
      final snapshot = await loveRef
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
    @override
    Widget build(BuildContext context) {
      return GestureDetector(
            onTap: () {
          print('✅ TAP OK: ${widget.trip.name}');
          widget.onTap?.call();
        },
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                  'assets/icons/logo_avt.svg'
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.trip.name + " ",
                    style: TextStyle(
                      color: Color(MyColor.black),
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    dayFormat(widget.trip.soNgay),
                    style: TextStyle(
                      color: Color(MyColor.black),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
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
                      onPressed: () {
                        _handleLovePressed();
                      },
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Hoạt động: ',
                              style: TextStyle(
                                color: Color(MyColor.black),
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              widget.trip.soAct.toString(),
                              style: TextStyle(
                                  color: Color(MyColor.pr5),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Bữa ăn: ",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${widget.trip.soEat}',
                              style: TextStyle(
                                color: Color(MyColor.pr5),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Text(
                              "Số người: ",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${widget.trip.soNguoi}',
                              style: TextStyle(
                                color: Color(MyColor.pr5),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Nơi ở: ',
                              style: TextStyle(
                                color: Color(MyColor.black),
                                fontSize: 16,
                              ),
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 150,
                              ),
                              child: Text(
                                widget.trip.noiO,
                                style: TextStyle(
                                  color: Color(MyColor.pr5),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis, // hien thi ... neu qua dai
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Chi phí: ",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "${NumberFormat("#,###", "vi_VN").format(widget.trip.chiPhi)}đ",
                              style: TextStyle(
                                color: Color(MyColor.pr5),
                                fontSize: 16,
                                fontWeight: FontWeight.w500
                              ),
                            )
                          ],
                        ),
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
                        ),

                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }


