import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class EditReviewScreen extends StatefulWidget {
  final Map<String, dynamic> review;
  final bool isNewReview;
  final String userId;

  const EditReviewScreen({
    super.key,
    required this.review,
    this.isNewReview = false,
    this.userId = '',
  });

  @override
  State<EditReviewScreen> createState() => _EditReviewScreenState();
}

class _EditReviewScreenState extends State<EditReviewScreen> {
  late int selectedRating;
  late TextEditingController commentController;
  bool _isSaving = false;
  Map<String, dynamic>? tripDetails;

  @override
  void initState() {
    super.initState();
    selectedRating = widget.review['rating'] ?? 0;
    commentController = TextEditingController(
      text: widget.review['comment'] ?? '',
    );
    _loadTripDetails();
  }

  Future<void> _loadTripDetails() async {
    if (widget.review['trip_id'] == null) return;

    try {
      String tripId = widget.review['trip_id'];
      print('Đang tải thông tin cho trip: $tripId');

      // Phương pháp 1: Thử tìm trong tất cả các location
      QuerySnapshot locationDocs =
          await FirebaseFirestore.instance.collection('dia_diem').get();

      for (var locationDoc in locationDocs.docs) {
        String locationId = locationDoc.id;
        print('Kiểm tra location: $locationId cho trip: $tripId');

        DocumentSnapshot tripDoc =
            await FirebaseFirestore.instance
                .collection('dia_diem')
                .doc(locationId)
                .collection('trips')
                .doc(tripId)
                .get();

        if (tripDoc.exists) {
          print('Đã tìm thấy trip trong location: $locationId');
          print('Trip data: ${tripDoc.data()}');
          setState(() {
            tripDetails = tripDoc.data() as Map<String, dynamic>?;
          });
          return; // Tìm thấy, dừng tìm kiếm
        }
      }

      // Phương pháp 2: Thử tìm bằng locationId nếu có
      if (widget.review['location_id'] != null &&
          widget.review['location_id'].toString().isNotEmpty) {
        String locationId = widget.review['location_id'];
        DocumentSnapshot tripDoc =
            await FirebaseFirestore.instance
                .collection('dia_diem')
                .doc(locationId)
                .collection('trips')
                .doc(tripId)
                .get();

        if (tripDoc.exists) {
          print('Đã tìm thấy trip với location_id được cung cấp: $locationId');
          setState(() {
            tripDetails = tripDoc.data() as Map<String, dynamic>?;
          });
          return;
        }
      }

      print('Không tìm thấy trip_id: $tripId trong bất kỳ location nào');
    } catch (e) {
      print('Lỗi khi tải thông tin trip: $e');
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> _saveReview() async {
    if (selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao đánh giá')),
      );
      return;
    }

    if (commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập bình luận của bạn')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userId =
          widget.userId.isEmpty
              ? FirebaseAuth.instance.currentUser?.uid
              : widget.userId;

      if (userId == null) {
        throw Exception("Người dùng chưa đăng nhập");
      }

      if (widget.isNewReview) {
        // Tạo đánh giá mới
        await FirebaseFirestore.instance.collection('reviews').add({
          'user_id': userId,
          'trip_id': widget.review['trip_id'],
          'comment': commentController.text.trim(),
          'votes': selectedRating,
          'created_at': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm đánh giá thành công')),
        );
      } else {
        // Cập nhật đánh giá hiện có
        await FirebaseFirestore.instance
            .collection('reviews')
            .doc(widget.review['id'])
            .update({
              'comment': commentController.text.trim(),
              'votes': selectedRating,
              'updated_at': Timestamp.now(),
            });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật đánh giá thành công')),
        );
      }

      Navigator.pop(
        context,
        true,
      ); // Trở về màn hình trước với kết quả thành công
    } catch (e) {
      print('Lỗi khi lưu đánh giá: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã xảy ra lỗi: $e')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  String _ratingText(int rating) {
    switch (rating) {
      case 5:
        return 'Tuyệt vời';
      case 4:
        return 'Rất tốt';
      case 3:
        return 'Tốt';
      case 2:
        return 'Tạm được';
      case 1:
        return 'Tệ';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(MyColor.white),
      appBar: AppBar(
        backgroundColor: Color(MyColor.white),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(MyColor.black)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.review['location']} ${widget.review['duration']}',
          style: TextStyle(
            color: Color(MyColor.black),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SvgPicture.asset(
              'assets/icons/logo.svg',
              height: 32,
              width: 32,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  tripDetails != null && tripDetails!['anh'] != null
                      ? Image.network(
                        tripDetails!['anh'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Lỗi tải ảnh từ tripDetails: $error');
                          // Thử lấy từ widget.review['imageUrl']
                          return (widget.review['imageUrl'] != null &&
                                  widget.review['imageUrl']
                                      .toString()
                                      .isNotEmpty &&
                                  widget.review['imageUrl']
                                      .toString()
                                      .startsWith('http'))
                              ? Image.network(
                                widget.review['imageUrl'],
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print(
                                    'Lỗi tải ảnh từ review imageUrl: $error',
                                  );
                                  return Image.asset(
                                    'assets/images/vungtau.png',
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                              : Image.asset(
                                'assets/images/vungtau.png',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              );
                        },
                      )
                      : (widget.review['imageUrl'] != null &&
                          widget.review['imageUrl'].toString().isNotEmpty &&
                          widget.review['imageUrl'].toString().startsWith(
                            'http',
                          ))
                      ? Image.network(
                        widget.review['imageUrl'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Lỗi tải ảnh từ review imageUrl: $error');
                          return Image.asset(
                            'assets/images/vungtau.png',
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                      : Image.asset(
                        'assets/images/vungtau.png',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                SvgPicture.asset('assets/icons/logo_avt.svg', height: 24),
                const SizedBox(width: 8),
                Text(
                  '${widget.review['duration']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(MyColor.black),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (tripDetails != null)
              Container(
                decoration: BoxDecoration(
                  color: Color(MyColor.pr1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Hoạt động: ${tripDetails!['so_act'] ?? 0}',
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Nơi ở: ${tripDetails!['noi_o'] ?? "Không có"}',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Bữa ăn: ${tripDetails!['so_eat'] ?? 0}'),
                        ),
                        Expanded(
                          child: Text(
                            'Chi phí: ${tripDetails!['chi_phi'] ?? 0}đ',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Số người: ${tripDetails!['so_nguoi'] ?? 1}',
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Số ngày: ${tripDetails!['so_ngay'] ?? 0}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Color(MyColor.pr1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Hoạt động: ${widget.review['activities'] ?? 15}',
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Nơi ở: ${widget.review['accommodation'] ?? "Không có"}',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Bữa ăn: ${widget.review['meals'] ?? 9}'),
                        ),
                        Expanded(
                          child: Text(
                            'Chi phí: ${widget.review['price'] ?? 0}đ',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Số người: ${widget.review['people'] ?? 1}',
                          ),
                        ),
                        const Expanded(child: Text('')),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chất lượng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  _ratingText(selectedRating),
                  style: TextStyle(color: Color(MyColor.pr5), fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      selectedRating = index + 1;
                    });
                  },
                  icon: Icon(
                    Icons.star,
                    size: 32,
                    color:
                        index < selectedRating
                            ? Colors.amber
                            : Color(MyColor.grey),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(MyColor.grey)),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: commentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Hãy chia sẻ nhận xét của bạn',
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(MyColor.white),
                  foregroundColor: Color(MyColor.pr5),
                  side: BorderSide(color: Color(MyColor.pr5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    _isSaving
                        ? CircularProgressIndicator(color: Color(MyColor.pr5))
                        : const Text('Gửi đánh giá'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
