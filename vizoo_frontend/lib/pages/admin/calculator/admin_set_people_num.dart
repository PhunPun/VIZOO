import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class AdminSetPeopleNum extends StatefulWidget {
  final int peopleNum; // so nguoi
  final int cost; // chi phi
  final ValueChanged<int> onSetPeople;
  final ValueChanged<int> onSetCost;
  final String diaDiemId;
  final String tripId;
  const AdminSetPeopleNum({
    super.key,
    required this.peopleNum,
    required this.cost,
    required this.onSetPeople,
    required this.onSetCost,
    required this.diaDiemId,
    required this.tripId,
  });

  @override
  State<AdminSetPeopleNum> createState() => _AdminSetPeopleNumState();
}

class _AdminSetPeopleNumState extends State<AdminSetPeopleNum> {
  late int peopleNum;
  late int cost;
  @override
  void initState(){
    super.initState();
    peopleNum = widget.peopleNum;
    cost = widget.cost;
  }
  Future<void> _updateFirestorePeopleAndCost() async {
    await FirebaseFirestore.instance
        .collection('dia_diem')
        .doc(widget.diaDiemId)
        .collection('trips')
        .doc(widget.tripId)
        .update({
      'so_nguoi': peopleNum,
      'chi_phi': cost,
    });
  }

  void _setCost() {
    setState(() {
      cost = (widget.cost * peopleNum) ~/ widget.peopleNum;
      widget.onSetCost(cost);
    });
    _updateFirestorePeopleAndCost();
  }
  void _incremetPeople(){
    if(peopleNum < 50){
      setState(() {
        peopleNum++;
        _setCost();
        widget.onSetPeople(peopleNum);
      });
    }
  }
  void _decrementPeople(){
    if(peopleNum > 1){
      setState(() {
        peopleNum--;
        _setCost();
        widget.onSetPeople(peopleNum);
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