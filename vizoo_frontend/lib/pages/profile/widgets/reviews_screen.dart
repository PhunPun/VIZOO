import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vizoo_frontend/pages/profile/widgets/edit_reviews_screen.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

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
      body: const ReviewTabView(),
    );
  }
}

class ReviewTabView extends StatefulWidget {
  const ReviewTabView({super.key});

  @override
  State<ReviewTabView> createState() => _ReviewTabViewState();
}

class _ReviewTabViewState extends State<ReviewTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    return Column(
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
            children: [MyReviewsTab(), PendingReviewsTab()],
          ),
        ),
      ],
    );
  }
}

class MyReviewsTab extends StatelessWidget {
  MyReviewsTab({super.key});

  final List<Map<String, dynamic>> myReviews = [
    {
      'location': 'Vũng Tàu',
      'duration': '3 ngày 2 đêm',
      'rating': 4,
      'comment':
          'Chuyến đi tuyệt vời! Phòng ở sạch sẽ, thoáng mát. Hướng dẫn viên nhiệt tình. Sẽ quay lại lần sau.',
      'date': '12/03/2025',
      'imageUrl': 'assets/images/vungtau.png',
    },
    {
      'location': 'Đà Lạt',
      'duration': '2 ngày 1 đêm',
      'rating': 5,
      'comment': 'Không khí mát mẻ, cảnh đẹp, đồ ăn ngon. Rất hài lòng!',
      'date': '05/03/2025',
      'imageUrl': 'assets/images/vungtau.png',
    },
    {
      'location': 'Phú Quốc',
      'duration': '4 ngày 3 đêm',
      'rating': 3,
      'comment':
          'Cảnh đẹp nhưng dịch vụ chưa tốt. Một số vấn đề về vệ sinh và phục vụ.',
      'date': '28/02/2025',
      'imageUrl': 'assets/images/vungtau.png',
    },
    {
      'location': 'Hạ Long',
      'duration': '3 ngày 2 đêm',
      'rating': 5,
      'comment': 'Tuyệt vời từ đầu đến cuối. Du thuyền sang trọng và món ăn đậm đà.',
      'date': '20/02/2025',
      'imageUrl': 'assets/images/vungtau.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return myReviews.isEmpty
        ? Center(
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
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myReviews.length,
            itemBuilder: (context, index) {
              final review = myReviews[index];
              return _buildReviewCard(context, review);
            },
          );
  }

  Widget _buildReviewCard(BuildContext context, Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(MyColor.pr3), width: 1),
      ),
      color: Color(MyColor.white),
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/logo_avt.svg',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${review['location']} ${review['duration']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(MyColor.pr5),
                    ),
                  ),
                ),
                Text(
                  review['date'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              review['imageUrl'],
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
                );
              },
            ),
          ),
          Container(
            color: Color(MyColor.pr2),
            padding: const EdgeInsets.all(12),
            child: Column(
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
                _buildRating(review['rating']),
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
                  review['comment'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(MyColor.black),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditReviewScreen(review: review),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(MyColor.white),
                        foregroundColor: Color(MyColor.pr5),
                        side: BorderSide(color: Color(MyColor.pr5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Chỉnh sửa'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(MyColor.pr3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Xóa'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRating(int rating) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: index < rating ? Colors.amber : Colors.grey,
          size: 20,
        ),
      ),
    );
  }
}

class PendingReviewsTab extends StatelessWidget {
  PendingReviewsTab({super.key});

  final List<Map<String, dynamic>> pendingReviews = [
    {
      'location': 'Nha Trang',
      'duration': '5 ngày 4 đêm',
      'completion_date': '05/04/2025',
      'imageUrl': 'assets/images/vungtau.png',
      'rating': 0,
      'comment': '',
    },
    {
      'location': 'Hội An',
      'duration': '4 ngày 3 đêm',
      'completion_date': '30/03/2025',
      'imageUrl': 'assets/images/vungtau.png',
      'rating': 0,
      'comment': '',
    },
    {
      'location': 'Huế',
      'duration': '3 ngày 2 đêm',
      'completion_date': '22/03/2025',
      'imageUrl': 'assets/images/vungtau.png',
      'rating': 0,
      'comment': '',
    },
    {
      'location': 'Cần Thơ',
      'duration': '2 ngày 1 đêm',
      'completion_date': '15/03/2025',
      'imageUrl': 'assets/images/vungtau.png',
      'rating': 0,
      'comment': '',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return pendingReviews.isEmpty
        ? Center(
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
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingReviews.length,
            itemBuilder: (context, index) {
              final trip = pendingReviews[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditReviewScreen(review: trip),
                    ),
                  );
                },
                child: _buildPendingReviewCard(context, trip),
              );
            },
          );
  }

  Widget _buildPendingReviewCard(
    BuildContext context,
    Map<String, dynamic> trip,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(MyColor.pr3), width: 1),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/logo_avt.svg',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${trip['location']} ${trip['duration']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(MyColor.pr5),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(MyColor.pr1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Chưa đánh giá',
                    style: TextStyle(
                      color: Color(MyColor.pr4),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              trip['imageUrl'],
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Bạn đã hoàn thành chuyến đi ngày ${trip['completion_date']}',
              style: const TextStyle(fontSize: 14, color: Color(MyColor.black)),
            ),
          ),
        ],
      ),
    );
  }
}
