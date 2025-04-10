import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:intl/intl.dart';

class TripCard extends StatefulWidget {
  final String address; // dia diem
  final String imageUrl; //
  final String dayNum; // so ngay
  final int activitiesNum; // so hoat dong
  final int mealNum; // so bua an
  final int peopleNum; // so nguoi
  final String residence; // noi o
  final int cost; // chi phi
  final int rating; // danh gia
  final VoidCallback? onTap;

  const TripCard({
    super.key,
    required this.address,
    required this.imageUrl,
    required this.dayNum,
    required this.activitiesNum,
    required this.mealNum,
    required this.peopleNum,
    required this.residence,
    required this.cost,
    required this.rating,
    this.onTap
  });

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  bool _loved = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 8,),
            Row(
              children: [
                const SizedBox(width: 8,),
                SvgPicture.asset(
                  'assets/icons/logo_avt.svg'
                ),
                const SizedBox(width: 8,),
                Text(
                  widget.address,
                  style: TextStyle(
                    color: Color(MyColor.black),
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(width: 5,),
                Text(
                  widget.dayNum,
                  style: TextStyle(
                    color: Color(MyColor.black),
                    fontSize: 13,
                    fontWeight: FontWeight.w400
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3,),
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.imageUrl),
                      fit: BoxFit.cover
                    )
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _loved = !_loved;
                      });
                    }, 
                    icon: Icon(
                      Icons.favorite, 
                      color: Color( _loved 
                        ? MyColor.red 
                        : MyColor.white
                      ),
                      shadows: [
                        Shadow(
                          color: Color(MyColor.black),
                          blurRadius: 4.0,
                          offset: Offset(0, 0.5),
                        )
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
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Hoạt đông: ',
                            style: TextStyle(
                              color: Color(MyColor.black),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.activitiesNum.toString(),
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
                            'Bữa ăn: ',
                            style: TextStyle(
                              color: Color(MyColor.black),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.mealNum.toString(),
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
                            'Số người: ',
                            style: TextStyle(
                              color: Color(MyColor.black),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.peopleNum.toString(),
                            style: TextStyle(
                              color: Color(MyColor.pr5),
                              fontSize: 16,
                              fontWeight: FontWeight.w500
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
                              widget.residence,
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
                            'Chi phí: ',
                            style: TextStyle(
                              color: Color(MyColor.black),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "${NumberFormat("#,###", "vi_VN").format(widget.cost)}đ",
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
                            'Đánh giá địa điểm: ',
                            style: TextStyle(
                              color: Color(MyColor.black),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.rating.toString(),
                            style: TextStyle(
                              color: Color(MyColor.pr5),
                              fontSize: 16,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}