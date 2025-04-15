import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:intl/intl.dart';
import '../models/trip_models.dart';

class TripCard extends StatefulWidget {
  final Trips trip;
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

  // Hàm định dạng ngày tháng
  String getFormattedDate(DateTime date) {
    return DateFormat("dd/MM/yyyy").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
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
                Expanded(
                  child: Text(
                    widget.trip.ten,
                    style: TextStyle(
                      color: Color(MyColor.black),
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Text(
                  "${widget.trip.soNgay} ngày",
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
                      image: NetworkImage(widget.trip.hinh_anh),
                      fit: BoxFit.cover,
                    ),
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
                            'Bắt đầu: ',
                            style: TextStyle(
                              color: Color(MyColor.black),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            getFormattedDate(widget.trip.ngayBatDau),
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
                            "Số ngày: ",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${widget.trip.soNgay}',
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
                            "Mô tả: ",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${widget.trip.moTa}',
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
                            'Kết thúc: ',
                            style: TextStyle(
                              color: Color(MyColor.black),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            getFormattedDate(widget.trip.ngayBatDau),
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
                            '${widget.trip.chi_phi}'  +" VND",
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

