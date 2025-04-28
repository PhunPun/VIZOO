import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:vizoo_frontend/calculator/day_format.dart';
import 'package:vizoo_frontend/models/trip_models_json.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class AdminTripCard extends StatefulWidget {
  final Trip trip;
  final VoidCallback? onTap;
  const AdminTripCard({super.key, required this.trip, this.onTap});

  @override
  State<AdminTripCard> createState() => _AdminTripCardState();
}

class _AdminTripCardState extends State<AdminTripCard> {
  @override
  Future<void> _deleteTrip() async {
    try {
      await FirebaseFirestore.instance
          .collection('dia_diem')
          .doc(widget.trip.locationId)
          .collection('trips')
          .doc(widget.trip.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa chuyến đi thành công')),
      );

      // Bạn có thể gọi thêm setState hay callback để cập nhật lại giao diện sau khi xóa
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
                SvgPicture.asset('assets/icons/logo_avt.svg'),
                const SizedBox(width: 8),
                Text(
                  widget.trip.name + " ",
                  style: TextStyle(
                    color: Color(MyColor.black),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
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
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Color(MyColor.pr5),
                        shadows: [
                          Shadow(
                            color: Color(MyColor.black),
                            blurRadius: 4.0,
                            offset: const Offset(0, 0.5),
                          ),
                        ],
                      ),
                      onSelected: (value) async {
                        if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Xác nhận'),
                                  content: const Text(
                                    'Bạn có chắc chắn muốn xóa chuyến đi này không?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('Hủy'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text('Xóa'),
                                    ),
                                  ],
                                ),
                          );

                          if (confirm == true) {
                            // 🛠️ Gọi Firestore xóa trip
                            await _deleteTrip();
                          }
                        }
                      },
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Xóa chuyến đi'),
                            ),
                          ],
                    ),
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
                              fontWeight: FontWeight.w500,
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
                            constraints: BoxConstraints(maxWidth: 150),
                            child: Text(
                              widget.trip.noiO,
                              style: TextStyle(
                                color: Color(MyColor.pr5),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow:
                                  TextOverflow
                                      .ellipsis, // hien thi ... neu qua dai
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
