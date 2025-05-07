import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/pages/profile/widgets/trip_review_widget.dart';
import 'package:vizoo_frontend/pages/profile/pages/edit_reviews_screen.dart';
import 'package:vizoo_frontend/pages/profile/widgets/trip_reviews_card.dart';
import '../widgets/trip_data_service.dart'; // Import service mới

class ReviewListView extends StatefulWidget {
  const ReviewListView({super.key});

  @override
  State<ReviewListView> createState() => _ReviewListViewState();
}

class _ReviewListViewState extends State<ReviewListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final TripDataService _tripService = TripDataService(); // Sử dụng service mới

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(MyColor.white),
      appBar: AppBar(
        backgroundColor: Color(MyColor.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(MyColor.black)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Đánh giá',
          style: TextStyle(
            color: Color(MyColor.black),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SvgPicture.asset(
              'assets/icons/logo.svg',
              height: 30,
              width: 30,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Color(MyColor.white),
            child: TabBar(
              controller: _tabController,
              labelColor: Color(MyColor.pr5),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(MyColor.pr5),
              tabs: const [
                Tab(text: 'Đánh giá của tôi'),
                Tab(text: 'Cần đánh giá'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildMyReviewsTab(), _buildPendingReviewsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyReviewsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _tripService.getUserReviews(), // Sử dụng service để lấy dữ liệu
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
        }

        final reviewDocs = snapshot.data ?? [];

        if (reviewDocs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/complain.png', height: 120),
                const SizedBox(height: 16),
                const Text(
                  'Bạn chưa có đánh giá nào',
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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reviewDocs.length,
          itemBuilder: (context, index) {
            final reviewData = reviewDocs[index];
            final reviewId = reviewData['id'] as String;
            final tripId = reviewData['trip_id'] as String? ?? '';

            return TripReviewWidget(tripId: tripId, reviewId: reviewId);
          },
        );
      },
    );
  }

  Widget _buildPendingReviewsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _tripService.getPendingReviews(), // Sử dụng service để lấy dữ liệu
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
        }

        final pendingReviews = snapshot.data ?? [];

        if (pendingReviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/complain.png', height: 120),
                const SizedBox(height: 16),
                const Text(
                  'Không có lịch trình nào cần đánh giá',
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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingReviews.length,
          itemBuilder: (context, index) {
            final trip = pendingReviews[index];
            return _buildPendingReviewCard(context, trip);
          },
        );
      },
    );
  }

  Widget _buildPendingReviewCard(
    BuildContext context,
    Map<String, dynamic> trip,
  ) {
    // Action buttons
    final List<Widget> actionButtons = [
      ElevatedButton(
        onPressed: () {
          _navigateToCreateReview(context, trip);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(MyColor.pr3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Đánh giá ngay'),
      ),
    ];

    // Extra content
    final Widget extraContent = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Bạn đã hoàn thành chuyến đi này vào ngày ${trip['completion_date']}',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Color(MyColor.pr4),
        ),
      ),
    );

    return TripDisplayCard(
      trip: trip,
      statusText: 'Chưa đánh giá',
      statusColor: Color(MyColor.pr4),
      borderColor: Color(MyColor.pr3),
      actionButtons: actionButtons,
      extraContent: extraContent,
    );
  }

  void _navigateToCreateReview(
    BuildContext context,
    Map<String, dynamic> trip,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditReviewScreen(
              review: trip,
              isNewReview: true,
              userId: currentUserId,
            ),
      ),
    ).then((_) {
      setState(() {});
    });
  }
}