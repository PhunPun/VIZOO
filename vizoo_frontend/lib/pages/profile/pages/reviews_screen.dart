// lib/pages/profile/pages/review_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/pages/profile/widgets/trip_review_widget.dart';
import 'package:vizoo_frontend/pages/profile/pages/edit_reviews_screen.dart';
import 'package:vizoo_frontend/pages/profile/widgets/trip_reviews_card.dart';

class ReviewListView extends StatefulWidget {
  const ReviewListView({super.key});

  @override
  State<ReviewListView> createState() => _ReviewListViewState();
}

class _ReviewListViewState extends State<ReviewListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

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
    return FutureBuilder<QuerySnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('reviews')
              .where('user_id', isEqualTo: currentUserId)
              .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
        }

        final reviewDocs = snapshot.data?.docs ?? [];

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
            final reviewData = reviewDocs[index].data() as Map<String, dynamic>;
            final reviewId = reviewDocs[index].id;
            final tripId = reviewData['trip_id'] as String? ?? '';

            return TripReviewWidget(tripId: tripId, reviewId: reviewId);
          },
        );
      },
    );
  }

  Widget _buildPendingReviewsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchPendingReviews(),
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

  Future<List<Map<String, dynamic>>> _fetchPendingReviews() async {
    if (currentUserId.isEmpty) return [];

    try {
      // Get completed trips (check = 1) for the user
      final userTripsSnapshot =
          await FirebaseFirestore.instance
              .collection('user_trip')
              .where('user_id', isEqualTo: currentUserId)
              .where('check', isEqualTo: 1) // Completed
              .get();

      List<String> completedTripIds =
          userTripsSnapshot.docs
              .map((doc) => doc.data()['trip_id'] as String? ?? '')
              .where((id) => id.isNotEmpty)
              .toList();

      // Get existing reviews
      final existingReviewsSnapshot =
          await FirebaseFirestore.instance
              .collection('reviews')
              .where('user_id', isEqualTo: currentUserId)
              .get();

      // Filter trip_ids that already have reviews
      List<String> reviewedTripIds =
          existingReviewsSnapshot.docs
              .map((doc) => doc.data()['trip_id'] as String? ?? '')
              .where((id) => id.isNotEmpty)
              .toList();

      // Filter trips that haven't been reviewed
      List<String> pendingTripIds =
          completedTripIds
              .where((tripId) => !reviewedTripIds.contains(tripId))
              .toList();

      List<Map<String, dynamic>> pendingReviews = [];

      // Get all locations
      final locationDocs =
          await FirebaseFirestore.instance.collection('dia_diem').get();

      // Tạo danh sách location để tra cứu
      final locations = Map.fromEntries(
        locationDocs.docs.map((doc) => MapEntry(doc.id, doc.data())),
      );

      for (var tripId in pendingTripIds) {
        // Tìm trip trong tất cả các location
        Map<String, dynamic>? tripData;
        Map<String, dynamic>? locationData;
        String? locationId;

        for (var location in locations.entries) {
          final locId = location.key;
          final locData = location.value;

          final tripSnapshot =
              await FirebaseFirestore.instance
                  .collection('dia_diem')
                  .doc(locId)
                  .collection('trips')
                  .doc(tripId)
                  .get();

          if (tripSnapshot.exists) {
            tripData = tripSnapshot.data();
            locationData = locData;
            locationId = locId;
            break;
          }
        }

        if (tripData != null && locationData != null && locationId != null) {
          // Handle dates
          Timestamp? startDateTimestamp =
              tripData['ngay_bat_dau'] as Timestamp?;
          int soDays =
              tripData['so_ngay'] is int
                  ? tripData['so_ngay'] as int
                  : int.tryParse(tripData['so_ngay'].toString()) ?? 0;

          // Calculate completion date
          String completionDate = 'Không xác định';
          if (startDateTimestamp != null && soDays > 0) {
            try {
              DateTime startDate = startDateTimestamp.toDate();
              DateTime endDate = startDate.add(Duration(days: soDays));
              completionDate =
                  '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
            } catch (e) {
              print('Error calculating completion date: $e');
            }
          }

          // Create pending review object
          Map<String, dynamic> pendingReview = {
            'trip_id': tripId,
            'location_id': locationId,
            'location': locationData['ten'] ?? 'Không xác định',
            'duration': '$soDays ngày ${soDays > 1 ? (soDays - 1) : 0} đêm',
            'completion_date': completionDate,
            // Sử dụng đúng trường hình ảnh
            'imageUrl':
                tripData['anh'] ??
                locationData['hinh_anh1'] ??
                'assets/images/vungtau.png',
            'rating': 0,
            'comment': '',
            'accommodation': tripData['noi_o'] ?? 'Không xác định',
            'price': tripData['chi_phi'] ?? 0,
            'people': tripData['so_nguoi'] ?? 1,
            'activities': tripData['so_act'] ?? 0,
            'meals': tripData['so_eat'] ?? 0,
            'userTripDocId':
                userTripsSnapshot.docs
                    .firstWhere((doc) => doc.data()['trip_id'] == tripId)
                    .id,
          };

          pendingReviews.add(pendingReview);
        }
      }

      return pendingReviews;
    } catch (e) {
      print('Error fetching pending reviews: $e');
      return [];
    }
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
