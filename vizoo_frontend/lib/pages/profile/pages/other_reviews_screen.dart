import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import '../widgets/trip_data_service.dart';

class OtherReviewsScreen extends StatefulWidget {
  final String tripId;
  final String locationName;
  final String tripDuration;
  final String? seTripId;
  const OtherReviewsScreen({
    super.key,
    required this.tripId,
    this.seTripId,
    required this.locationName,
    required this.tripDuration,
  });

  @override
  State<OtherReviewsScreen> createState() => _OtherReviewsScreenState();
}

class _OtherReviewsScreenState extends State<OtherReviewsScreen> {
  final TripDataService _tripService = TripDataService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _reviews = [];
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _debugReviewInfo() async {
    try {
      // Truy vấn tất cả đánh giá cho trip_id, không lọc se_trip_id
      final allReviewsQuery = FirebaseFirestore.instance
          .collection('reviews')
          .where('trip_id', isEqualTo: widget.tripId);

      final allReviewsDocs = await allReviewsQuery.get();

      // Truy vấn đánh giá có se_trip_id
      final withSeTripIdQuery =
          widget.seTripId != null && widget.seTripId!.isNotEmpty
              ? FirebaseFirestore.instance
                  .collection('reviews')
                  .where('trip_id', isEqualTo: widget.tripId)
                  .where('se_trip_id', isEqualTo: widget.seTripId)
              : null;

      final withSeTripIdDocs =
          withSeTripIdQuery != null ? await withSeTripIdQuery.get() : null;

      // Hiển thị debug dialog
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Debug Thông tin Đánh giá'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Trip ID: ${widget.tripId}'),
                    Text('Se Trip ID: ${widget.seTripId ?? "Không có"}'),
                    Divider(),
                    Text(
                      'Tổng số đánh giá theo trip_id: ${allReviewsDocs.size}',
                    ),
                    if (withSeTripIdDocs != null)
                      Text(
                        'Số đánh giá có cả trip_id và se_trip_id: ${withSeTripIdDocs.size}',
                      ),
                    Divider(),
                    Text('Số đánh giá hiển thị hiện tại: ${_reviews.length}'),
                    Text(
                      'Số đánh giá có bình luận: ${_reviews.where((r) => (r['comment'] ?? '').isNotEmpty).length}',
                    ),
                    Divider(),
                    Text('Chi tiết các đánh giá (trip_id):'),
                    ...allReviewsDocs.docs.map((doc) {
                      final data = doc.data();
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                        child: Text(
                          '- User: ${data['user_id']?.toString()?.substring(0, 8) ?? "?"}, '
                          'seTripId: ${data['se_trip_id'] ?? "không có"}, '
                          'Votes: ${data['votes'] ?? "0"}, '
                          'Comment: ${(data['comment'] ?? "").isEmpty ? "Không có" : "Có"}',
                          style: TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Đóng'),
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi debug: $e')));
    }
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Xóa cache để đảm bảo lấy dữ liệu mới nhất
      _tripService.clearCache();

      // Lấy tất cả đánh giá của người dùng khác, truyền cả seTripId
      final otherReviews = await _tripService.getOtherUserReviews(
        widget.tripId,
        seTripId: widget.seTripId,
      );

      // Lấy điểm đánh giá trung bình - cũng truyền seTripId
      final averageRating = await _tripService.getTripAverageRating(
        widget.tripId,
        seTripId: widget.seTripId,
      );

      // Đếm tổng số đánh giá, bao gồm cả của người dùng hiện tại
      final countReviewsQuery =
          widget.seTripId != null && widget.seTripId!.isNotEmpty
              ? FirebaseFirestore.instance
                  .collection('reviews')
                  .where('trip_id', isEqualTo: widget.tripId)
                  .where('se_trip_id', isEqualTo: widget.seTripId)
              : FirebaseFirestore.instance
                  .collection('reviews')
                  .where('trip_id', isEqualTo: widget.tripId);

      final allReviewsSnapshot = await countReviewsQuery.get();
      final int totalReviews = allReviewsSnapshot.size;

      if (mounted) {
        setState(() {
          _reviews = otherReviews;
          _averageRating = averageRating;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải đánh giá: $e')));
      }
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Đánh giá từ người dùng khác',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SvgPicture.asset('assets/icons/logo.svg'),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildReviewsList(),
    );
  }

  Widget _buildReviewsList() {
    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/complain.png', height: 120),
            const SizedBox(height: 16),
            const Text(
              'Chưa có đánh giá nào từ người dùng khác',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Roboto',
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header với thông tin trip và đánh giá trung bình
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(MyColor.pr1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset('assets/icons/logo_avt.svg', height: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.locationName} ${widget.tripDuration}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Đánh giá trung bình: ',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    _averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      color: Color(MyColor.pr5),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '(${_reviews.length} đánh giá)', // Chỉ hiển thị số lượng đánh giá người khác
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              // Thêm text debug (có thể xóa sau khi fix)
              Text(
                'Hiển thị ${_reviews.length} đánh giá, có ${_reviews.where((r) => (r['comment'] ?? '').isNotEmpty).length} đánh giá có bình luận',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ),

        // Danh sách đánh giá
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _reviews.length,
            itemBuilder: (context, index) {
              final review = _reviews[index];
              return _buildReviewCard(review);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final int rating =
        review['votes'] is int
            ? review['votes']
            : int.tryParse(review['votes']?.toString() ?? '0') ?? 0;

    final String comment = review['comment'] ?? '';
    final String userName = review['userName'] ?? 'Người dùng khác';
    final String date = review['formattedDate'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(MyColor.pr2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin người dùng và ngày
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(MyColor.pr3),
                      radius: 20,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        if (date.isNotEmpty)
                          Text(
                            date,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '$rating',
                        style: TextStyle(
                          color: Colors.amber[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.star, color: Colors.amber, size: 16),
                    ],
                  ),
                ),
              ],
            ),

            // Đánh giá sao
            const SizedBox(height: 12),
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

            // Bình luận
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Nhận xét:',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(comment, style: TextStyle(fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }
}
