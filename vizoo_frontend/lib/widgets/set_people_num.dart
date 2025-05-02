import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../pages/timeline/timeline_page.dart';


class SetPeopleNum extends StatefulWidget {
  final int peopleNum; // so nguoi
  final int cost; // chi phi
  final ValueChanged<int> onSetPeople;
  final ValueChanged<int> onSetCost;
  final String diaDiemId;
  final String tripId;
  const SetPeopleNum({
    super.key,
    required this.peopleNum,
    required this.cost,
    required this.onSetPeople,
    required this.onSetCost,
    required this.diaDiemId,
    required this.tripId,
  });


  @override
  State<SetPeopleNum> createState() => _SetPeopleNumState();
}

class _SetPeopleNumState extends State<SetPeopleNum> {
  late int peopleNum;
  late int cost;
  late DocumentReference userTripRef;
  bool _userTripExists = false;
  StreamSubscription<DocumentSnapshot>? _sub;
  @override
  @override
  void initState() {
    super.initState();
    peopleNum = widget.peopleNum;
    cost = widget.cost;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userTripRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('selected_trips')
          .doc(widget.tripId);
      _initUserTrip();
    }
  }
  Future<void> _initUserTrip() async {
    final snap = await userTripRef.get();
    if (snap.exists) {
      _userTripExists = true;
      final data = snap.data() as Map<String, dynamic>;
      setState(() {
        peopleNum = data['so_nguoi'] as int? ?? peopleNum;
        cost = data['chi_phi'] as int? ?? cost;
      });
      widget.onSetPeople(peopleNum);
      widget.onSetCost(cost);
    }
    // lắng nghe thay đổi sau này
    _sub = userTripRef.snapshots().listen((snap) {
      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;
        setState(() {
          peopleNum = data['so_nguoi'] as int? ?? peopleNum;
          cost = data['chi_phi'] as int? ?? cost;
        });
        widget.onSetPeople(peopleNum);
        widget.onSetCost(cost);
      }
    });
  }
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// cập nhật số người và chi phí lên bảng user
  Future<void> _updateUserTripPeopleAndCost() async {
    await userTripRef.update({
      'so_nguoi': peopleNum,
      'chi_phi': cost,
    });
  }

  void _setCost() {
    setState(() {
      cost = (widget.cost * peopleNum) ~/ widget.peopleNum;
      widget.onSetCost(cost);
    });
  }
  Future<void> _syncToFirestore() async {
    final updateData = {
      'so_nguoi': peopleNum,
      'chi_phi': cost,
      'location_id': widget.diaDiemId,
    };
    if (_userTripExists) {
      await userTripRef.update(updateData);
    } else {
      await _addFullTripToUser();
    }
  }

  Future<void> _addFullTripToUser() async {
    final masterRef = FirebaseFirestore.instance
        .collection('dia_diem')
        .doc(widget.diaDiemId)
        .collection('trips')
        .doc(widget.tripId);
    final masterSnap = await masterRef.get();
    if (!masterSnap.exists) return;

    final masterData = masterSnap.data()!;
    // Copy main trip doc with location_id
    await userTripRef.set({
      ...masterData,
      'saved_at': FieldValue.serverTimestamp(),
      'so_nguoi': peopleNum,
      'chi_phi': cost,
      'location_id': widget.diaDiemId,
    }, SetOptions(merge: true));

    // Copy timelines and include location_id
    final tlSnap = await masterRef.collection('timelines').get();
    for (var tl in tlSnap.docs) {
      final tlData = tl.data();
      await userTripRef
          .collection('timelines')
          .doc(tl.id)
          .set({
        ...tlData,
        'location_id': widget.diaDiemId,
      }, SetOptions(merge: true));

      // Copy schedules and include location_id
      final schSnap = await tl.reference.collection('schedule').get();
      for (var sch in schSnap.docs) {
        final schData = sch.data();
        await userTripRef
            .collection('timelines')
            .doc(tl.id)
            .collection('schedule')
            .doc(sch.id)
            .set({
          ...schData,
          'location_id': widget.diaDiemId,
        }, SetOptions(merge: true));
      }
    }

    setState(() {
      _userTripExists = true;
    });

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TimelinePage(
        tripId: widget.tripId,
        locationId: widget.diaDiemId,
      ),
    ));
  }
  void _incremetPeople(){
    if(peopleNum < 50){
      setState(() async {
        peopleNum++;
        _setCost();
        widget.onSetPeople(peopleNum);
        if (_userTripExists) {
          await _updateUserTripPeopleAndCost();
        } else {
          await _addFullTripToUser();
        }
      });
    }
  }
  void _decrementPeople(){
    if(peopleNum > 1){
      setState(() async {
        peopleNum--;
        _setCost();
        widget.onSetPeople(peopleNum);
        if (_userTripExists) {
          await _updateUserTripPeopleAndCost();
        } else {
          await _addFullTripToUser();
        }
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(MyColor.pr3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    SvgPicture.asset('assets/icons/face.svg'),
                    const SizedBox(width: 8),
                    const Text(
                      'Số người',
                      style: TextStyle(
                        color: Color(MyColor.black),
                        fontSize: 18
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    peopleNum.toString(),
                    style: TextStyle(
                      color: Color(MyColor.black),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ),
              ),
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          _incremetPeople();
                        },
                        child: Text(
                          '+',
                          style: TextStyle(
                            color: Color(MyColor.pr4),
                            fontSize: 25,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                      Text('|'),
                      InkWell(
                        onTap: () {
                          _decrementPeople();
                        },
                        child: Text(
                          '—',
                          style: TextStyle(
                            color: Color(MyColor.pr4),
                            fontSize: 20,
                            fontWeight: FontWeight.w700
                          ),
                        ),
                      ),
                    ],
                  )
                ),
              ),
            ],
          ),
          Container(
            height: 2,
            margin: EdgeInsets.only(left: 15),
            color: Color(MyColor.pr5),
          )
        ],
      ),
    );
  }
}