import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class SetPeopleNum extends StatefulWidget {
  final int peopleNum; // so nguoi
  final int cost; // chi phi
  final ValueChanged<int> onSetPeople;
  final ValueChanged<int> onSetCost;
  const SetPeopleNum({
    super.key,
    required this.peopleNum,
    required this.cost,
    required this.onSetPeople,
    required this.onSetCost,
  });

  @override
  State<SetPeopleNum> createState() => _SetPeopleNumState();
}

class _SetPeopleNumState extends State<SetPeopleNum> {
  late int peopleNum;
  late int cost;
  @override
  void initState(){
    super.initState();
    peopleNum = widget.peopleNum;
    cost = widget.cost;
  }
  void _setCost(){
    setState(() {
      cost = (widget.cost*peopleNum)~/widget.peopleNum;
      widget.onSetCost(cost);
    });
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