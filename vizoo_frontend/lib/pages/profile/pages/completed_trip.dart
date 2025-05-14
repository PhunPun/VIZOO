import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/pages/timeline/timeline_page.dart';
import 'package:vizoo_frontend/pages/profile/pages/edit_reviews_screen.dart';
import 'package:vizoo_frontend/pages/profile/widgets/trip_reviews_card.dart';
import '../widgets/trip_data_service.dart';

class CompletedTripsScreen extends StatelessWidget {
  const CompletedTripsScreen({super.key});

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
        title: const Text(
          'Chuyến đi đã hoàn thành',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
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
      body: const CompletedTripsList(),
    );
  }
}

class CompletedTripsList extends StatefulWidget {
  const CompletedTripsList({super.key});

  @override
  State<CompletedTripsList> createState() => _CompletedTripsListState();
}

class _CompletedTripsListState extends State<CompletedTripsList> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _completedTrips = [];
  String _errorMessage = '';
  final TripDataService _tripService = TripDataService();
  
  @override
  void initState() {
    super.initState();
    _loadCompletedTrips();
  }
  
  Future<void> _loadCompletedTrips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Sử dụng service đã tối ưu để lấy dữ liệu trực tiếp từ user_trip và selected_trips
      final trips = await _tripService.getUserTrips(tripStatus: 1);
      
      setState(() {
        _completedTrips = trips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Đã xảy ra lỗi: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    if (_completedTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/complain.png', height: 120),
            const SizedBox(height: 16),
            const Text(
              'Bạn chưa có chuyến đi nào đã hoàn thành',
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

    return RefreshIndicator(
      onRefresh: _loadCompletedTrips,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _completedTrips.length,
        itemBuilder: (context, index) {
          final trip = _completedTrips[index];
          return _buildCompletedTripCard(context, trip);
        },
      ),
    );
  }

  Widget _buildCompletedTripCard(
    BuildContext context,
    Map<String, dynamic> trip,
  ) {
    // Tạo nút hành động
    final List<Widget> actionButtons = [
      ElevatedButton(
        onPressed: () {
          trip['rating'] > 0
              ? _navigateToEditReview(context, trip)
              : _navigateToReview(context, trip);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(MyColor.white),
          foregroundColor: Color(MyColor.pr5),
          side: BorderSide(color: Color(MyColor.pr5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(trip['rating'] > 0 ? 'Chỉnh sửa đánh giá' : 'Đánh giá ngay'),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TimelinePage(
                tripId: trip['trip_id'],
                locationId: trip['location_id'],
                se_tripId: trip['se_trip_id'],
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(MyColor.pr3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Xem chi tiết'),
      ),
    ];

    // Tạo widget nội dung bổ sung với ngày hoàn thành và đánh giá
    Widget extraContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Luôn hiển thị ngày hoàn thành
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Icon(Icons.event_available, color: Color(MyColor.pr4), size: 16),
              const SizedBox(width: 4),
              Text(
                'Hoàn thành vào ngày: ${trip['completion_date']}',
                style: TextStyle(
                  color: Color(MyColor.pr5),
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        
        // Hiển thị đánh giá nếu có
        if (trip['rating'] > 0) ...[
          Row(
            children: [
              const Text(
                'Đánh giá của bạn: ',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              _buildRatingStars(trip['rating']),
            ],
          ),
          if (trip['comment'] != null && trip['comment'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nhận xét:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trip['comment'],
                    style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ],
    );

    // Sử dụng TripDisplayCard component
    return TripDisplayCard(
      trip: trip,
      statusText: 'Hoàn thành',
      statusColor: Color(MyColor.pr5),
      borderColor: Color(MyColor.pr3),
      actionButtons: actionButtons,
      extraContent: extraContent,
    );
  }

  void _navigateToReview(BuildContext context, Map<String, dynamic> trip) {
    // Xây dựng dữ liệu cho trang đánh giá
    final reviewData = {
      'trip_id': trip['trip_id'],
      'location_id': trip['location_id'],
      'se_trip_id': trip['se_trip_id'],
      'location': trip['location'],
      'duration': trip['duration'],
      'rating': 0,
      'comment': '',
      'imageUrl': trip['imageUrl'],
      'accommodation': trip['accommodation'],
      'price': trip['price'],
      'people': trip['people'],
      'activities': trip['activities'],
      'meals': trip['meals'],
    };

    // Điều hướng đến trang đánh giá
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReviewScreen(
          review: reviewData,
          isNewReview: true,
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        ),
      ),
    ).then((result) {
      // Làm mới danh sách khi quay lại
      if (result == true) {
        _loadCompletedTrips();
      }
    });
  }

  void _navigateToEditReview(BuildContext context, Map<String, dynamic> trip) {
    // Xây dựng dữ liệu cho trang chỉnh sửa đánh giá
    final reviewData = {
      'id': trip['review_id'],
      'trip_id': trip['trip_id'],
      'location_id': trip['location_id'],
      'se_trip_id': trip['se_trip_id'],
      'location': trip['location'],
      'duration': trip['duration'],
      'rating': trip['rating'],
      'comment': trip['comment'],
      'imageUrl': trip['imageUrl'],
      'accommodation': trip['accommodation'],
      'price': trip['price'],
      'people': trip['people'],
      'activities': trip['activities'],
      'meals': trip['meals'],
    };

    // Điều hướng đến trang chỉnh sửa đánh giá
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReviewScreen(
          review: reviewData,
          isNewReview: false,
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        ),
      ),
    ).then((result) {
      // Làm mới danh sách khi quay lại
      if (result == true) {
        _loadCompletedTrips();
      }
    });
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: index < rating ? Colors.amber : Colors.grey,
          size: 16,
        ),
      ),
    );
  }
}