// lib/pages/profile/widgets/trip_review_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/pages/profile/widgets/trip_reviews_card.dart';
import 'package:vizoo_frontend/pages/profile/pages/edit_reviews_screen.dart';

class TripReviewWidget extends StatefulWidget {
  final String tripId;
  final String reviewId;

  const TripReviewWidget({
    super.key,
    required this.tripId,
    required this.reviewId,
  });

  @override
  State<TripReviewWidget> createState() => _TripReviewWidgetState();
}

class _TripReviewWidgetState extends State<TripReviewWidget> {
  bool _isLoading = true;
  Map<String, dynamic> _reviewData = {};
  Map<String, dynamic> _tripData = {};
  Map<String, dynamic> _locationData = {};

  @override
  void initState() {
    super.initState();
    _loadReviewData();
  }

  Future<void> _loadReviewData() async {
    try {
      // Fetch review data
      final reviewDoc =
          await FirebaseFirestore.instance
              .collection('reviews')
              .doc(widget.reviewId)
              .get();

      if (!reviewDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đánh giá không tồn tại')),
          );
          Navigator.pop(context);
        }
        return;
      }

      final reviewData = reviewDoc.data() as Map<String, dynamic>;
      final tripId = reviewData['trip_id'] as String;

      print('Đang tải dữ liệu review cho trip: $tripId');

      // Tìm trip trong tất cả các location
      QuerySnapshot locationDocs =
          await FirebaseFirestore.instance.collection('dia_diem').get();

      Map<String, dynamic> tripData = {};
      Map<String, dynamic> locationData = {};

      for (var locationDoc in locationDocs.docs) {
        String locationId = locationDoc.id;

        final tripDoc =
            await FirebaseFirestore.instance
                .collection('dia_diem')
                .doc(locationId)
                .collection('trips')
                .doc(tripId)
                .get();

        if (tripDoc.exists) {
          tripData = tripDoc.data() ?? {};
          locationData = locationDoc.data() as Map<String, dynamic>? ?? {};
          locationData['id'] = locationId; // Lưu locationId
          print('Đã tìm thấy trip trong location: $locationId');
          break;
        }
      }

      if (mounted) {
        setState(() {
          _reviewData = {'id': reviewDoc.id, ...reviewData};
          _tripData = tripData;
          _locationData = locationData;
          _isLoading = false;
        });

        print('Dữ liệu trip: $_tripData');
        print('Dữ liệu location: $_locationData');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteReview() async {
    bool confirm =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Xác nhận xóa'),
                content: const Text(
                  'Bạn có chắc chắn muốn xóa đánh giá này không?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Hủy', style: TextStyle(color: Color(MyColor.pr3)),),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Xóa', style: TextStyle(color: Color(MyColor.pr5)),),
                  ),
                ],
              ),
        ) ??
        false;

    if (!confirm) return;

    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(widget.reviewId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã xóa đánh giá')));
        Navigator.pop(context, true); // Return with deletion result
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa đánh giá: $e')));
      }
    }
  }

  String _formatRating(int rating) {
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final rating = _reviewData['votes'] ?? 0;
    final comment = _reviewData['comment'] ?? '';

    // Create review info for display in TripDisplayCard
    final Map<String, dynamic> tripReviewInfo = {
      'id': _reviewData['id'],
      'trip_id': _reviewData['trip_id'],
      'location_id':
          _locationData['id'] ?? _reviewData['trip_id'].split('_').first,
      'location': _locationData['ten'] ?? 'Không xác định',
      'duration':
          _tripData['so_ngay'] != null
              ? '${_tripData['so_ngay']} ngày ${int.parse(_tripData['so_ngay'].toString()) > 1 ? (int.parse(_tripData['so_ngay'].toString()) - 1) : 0} đêm'
              : '',
      'rating': rating,
      'comment': comment,
      'imageUrl': _locationData['hinh_anh1'] ?? 'assets/images/vungtau.png',
      'accommodation': _tripData['noi_o'] ?? 'Không xác định',
      'price': _tripData['chi_phi'] ?? 0,
      'people': _tripData['so_nguoi'] ?? 1,
      'activities': _tripData['so_act'] ?? 0,
      'meals': _tripData['so_eat'] ?? 0,
    };

    // Create action buttons
    final List<Widget> actionButtons = [
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => EditReviewScreen(
                    review: tripReviewInfo,
                    isNewReview: false,
                  ),
            ),
          ).then((result) {
            if (result == true) {
              _loadReviewData();
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(MyColor.white),
          foregroundColor: Color(MyColor.pr5),
          side: BorderSide(color: Color(MyColor.pr5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Chỉnh sửa'),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: _deleteReview,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(MyColor.pr3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Xóa'),
      ),
    ];

    // Create extra content with rating and comment
    final Widget extraContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chất lượng:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(MyColor.black),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: index < rating ? Colors.amber : Colors.grey,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              _formatRating(rating),
              style: TextStyle(
                color: Color(MyColor.pr5),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Bình luận:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(MyColor.black),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          comment,
          style: const TextStyle(fontSize: 14, color: Color(MyColor.black)),
        ),
        const SizedBox(height: 12),
      ],
    );

    return TripDisplayCard(
      trip: tripReviewInfo,
      statusText: 'Đã đánh giá',
      statusColor: Color(MyColor.pr5),
      borderColor: Color(MyColor.pr3),
      actionButtons: actionButtons,
      extraContent: extraContent,
    );
  }
}
