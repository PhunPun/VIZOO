import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/pages/profile/widgets/trip_reviews_card.dart';
import 'package:vizoo_frontend/pages/profile/pages/edit_reviews_screen.dart';
import '../pages/other_reviews_screen.dart';
import '../widgets/trip_data_service.dart';

class TripReviewWidget extends StatefulWidget {
  final String tripId;
  final String reviewId;
  final bool showOtherReviews; // Tham số để hiển thị nút xem đánh giá khác

  const TripReviewWidget({
    super.key,
    required this.tripId,
    required this.reviewId,
    this.showOtherReviews =
        false, // Mặc định không hiển thị nút xem đánh giá khác
  });

  @override
  State<TripReviewWidget> createState() => _TripReviewWidgetState();
}

class _TripReviewWidgetState extends State<TripReviewWidget> {
  bool _isLoading = true;
  Map<String, dynamic> _reviewData = {};
  Map<String, dynamic> _tripData = {};
  Map<String, dynamic> _locationData = {};
  double _averageRating = 0.0;
  int _totalReviews = 0;
  final TripDataService _tripService = TripDataService();

  @override
  void initState() {
    super.initState();
    _loadReviewData();
  }

  Future<void> _loadReviewData() async {
    try {
      // 1. Lấy dữ liệu đánh giá từ Firestore
      final reviewDoc =
          await FirebaseFirestore.instance
              .collection('reviews')
              .doc(widget.reviewId)
              .get();

      if (!reviewDoc.exists) {
        _handleError('Đánh giá không tồn tại');
        return;
      }

      final reviewData = reviewDoc.data() as Map<String, dynamic>;
      final tripId = reviewData['trip_id'] as String? ?? '';

      // Kiểm tra nếu có trip_details trong document
      Map<String, dynamic> tripDetails = {};
      if (reviewData.containsKey('trip_details') &&
          reviewData['trip_details'] is Map) {
        tripDetails = Map<String, dynamic>.from(reviewData['trip_details']);
      }

      String locationId = reviewData['location_id'] ?? '';
      String seTripId = reviewData['se_trip_id'] ?? '';

      // Nếu không có location_id trong review data, thử lấy từ tripId
      if (locationId.isEmpty && tripId.contains('_')) {
        final parts = tripId.split('_');
        if (parts.isNotEmpty) {
          locationId = parts[0];
        }
      }

      // 2. Lấy thêm dữ liệu trip nếu cần
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      Map<String, dynamic> seTripData = {};

      // Lấy dữ liệu từ selected_trip nếu có seTripId
      if (seTripId.isNotEmpty) {
        final seTripDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('selected_trips')
                .doc(seTripId)
                .get();

        if (seTripDoc.exists) {
          seTripData = seTripDoc.data() ?? {};

          // Cập nhật locationId từ selected_trip nếu có
          if (locationId.isEmpty &&
              seTripData.containsKey('location_id') &&
              seTripData['location_id'].toString().isNotEmpty) {
            locationId = seTripData['location_id'].toString();
          }
        }
      }

      // 3. Lấy thông tin vị trí
      Map<String, dynamic> locationData = {};
      if (locationId.isNotEmpty) {
        final locationDoc =
            await FirebaseFirestore.instance
                .collection('dia_diem')
                .doc(locationId)
                .get();

        if (locationDoc.exists) {
          locationData = locationDoc.data() ?? {};
          locationData['id'] = locationId;
        }
      }

      // 4. Tính điểm đánh giá trung bình
      final averageRating = await _tripService.getTripAverageRating(tripId);

      // Lấy tổng số đánh giá
      final reviewsSnapshot =
          await FirebaseFirestore.instance
              .collection('reviews')
              .where('trip_id', isEqualTo: tripId)
              .get();

      _totalReviews = reviewsSnapshot.docs.length;

      // 5. Ưu tiên sử dụng dữ liệu từ trip_details nếu có
      if (tripDetails.isNotEmpty) {
        // Sử dụng tripDetails để điền thông tin
        if (mounted) {
          setState(() {
            _reviewData = {'id': reviewDoc.id, ...reviewData};
            _tripData = {...seTripData, ...tripDetails};
            _locationData = locationData;
            _averageRating = averageRating;
            _isLoading = false;
          });
        }
      } else {
        // Sử dụng seTripData và locationData như cũ
        if (mounted) {
          setState(() {
            _reviewData = {'id': reviewDoc.id, ...reviewData};
            _tripData = seTripData;
            _locationData = locationData;
            _averageRating = averageRating;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      _handleError('Lỗi khi tải dữ liệu: $e');
    }
  }

  void _handleError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      setState(() {
        _isLoading = false;
      });
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
                    child: const Text(
                      'Hủy',
                      style: TextStyle(color: Color(MyColor.pr3)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Xóa',
                      style: TextStyle(color: Color(MyColor.pr5)),
                    ),
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
        Navigator.pop(context, true); // Trở về kèm kết quả thành công
      }
    } catch (e) {
      _handleError('Lỗi khi xóa đánh giá: $e');
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
  String _formatDuration(int soDays) {
  int soDem;
  if (soDays == 1) {
    soDem = 1;
  } else if (soDays == 2) {
    soDem = 1;
  } else if (soDays == 3) {
    soDem = 2;
  } else if (soDays == 4) {
    soDem = 3;
  } else if (soDays >= 5) {
    soDem = 4;
  } else {
    soDem = 0;
  }
  return '$soDays ngày $soDem đêm';
}
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final rating = _reviewData['votes'] ?? 0;
    final comment = _reviewData['comment'] ?? '';

    // Trích xuất thông tin cho TripDisplayCard
    final int soDays = _extractIntValue(_tripData, 'so_ngay', 1);
    int soDem;
    if (soDays == 1) {
      soDem = 1;
    } else if (soDays == 2) {
      soDem = 1;
    } else if (soDays == 3) {
      soDem = 2;
    } else if (soDays == 4) {
      soDem = 3;
    } else if (soDays >= 5) {
      soDem = 4;
    } else {
      soDem = 0;
    }

    // Tạo thông tin cho TripDisplayCard
    final Map<String, dynamic> tripReviewInfo = {
      'id': _reviewData['id'],
      'trip_id': _reviewData['trip_id'],
      'location_id':
          _locationData['id'] ?? _extractLocationId(_reviewData['trip_id']),
      'se_trip_id': _tripData['se_trip_id'] ?? '',
      'location': _locationData['ten'] ?? 'Không xác định',
      'duration': _formatDuration(soDays), 
      'rating': rating,
      'comment': comment,
      'imageUrl':
          _tripData['anh'] ??
          _locationData['hinh_anh1'] ??
          'assets/images/vungtau.png',
      'accommodation': _tripData['noi_o'] ?? 'Không xác định',
      'price': _extractIntValue(_tripData, 'chi_phi', 0),
      'people': _extractIntValue(_tripData, 'so_nguoi', 1),
      'activities': _extractIntValue(_tripData, 'so_act', 0),
      'meals': _extractIntValue(_tripData, 'so_eat', 0),
      'averageRating': _averageRating,
      'totalReviews': _totalReviews,
    };

    // Tạo các nút thao tác
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

    // Tạo nội dung bổ sung với đánh giá và bình luận
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

        // Hiển thị thông tin đánh giá trung bình nếu có
        if (_totalReviews > 1) // Chỉ hiển thị khi có nhiều hơn 1 đánh giá
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Đánh giá trung bình: ',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${_averageRating.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: Color(MyColor.pr5),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '($_totalReviews đánh giá)',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Nút xem đánh giá khác - chỉ hiển thị khi được kích hoạt
              if (widget.showOtherReviews)
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => OtherReviewsScreen(
                              tripId: widget.tripId,
                              seTripId: tripReviewInfo['se_trip_id'],
                              locationName: tripReviewInfo['location'],
                              tripDuration: tripReviewInfo['duration'],
                            ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.reviews, size: 16),
                  label: const Text('Xem đánh giá khác'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: Color(MyColor.pr4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
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

  // Trích xuất giá trị int từ Map
  int _extractIntValue(
    Map<String, dynamic> data,
    String key,
    int defaultValue,
  ) {
    if (!data.containsKey(key) || data[key] == null) return defaultValue;

    if (data[key] is int) return data[key];
    return int.tryParse(data[key].toString()) ?? defaultValue;
  }

  // Trích xuất location_id từ trip_id
  String _extractLocationId(String tripId) {
    if (tripId.contains('_')) {
      final parts = tripId.split('_');
      if (parts.isNotEmpty) {
        return parts[0];
      }
    }
    return '';
  }
}
