import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';


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
          'Completed Trip',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SvgPicture.asset(
              'assets/icons/logo.svg',
            ),
          ),
        ],
      ),
      body: const CompletedTripsList(),
    );
  }
}

class CompletedTripsList extends StatelessWidget {
  const CompletedTripsList({super.key});

  final List<Map<String, dynamic>> completedTrips = const [
    {
      'location': 'Vũng tàu',
      'duration': '3 ngày 2 đêm',
      'activities': 15,
      'meals': 9,
      'people': 1,
      'accommodation': 'Nhà nghỉ kim phụng',
      'price': 2500000,
      'rating': 4,
      'imageUrl': 'assets/images/vungtau.png',
    },
    {
      'location': 'Đà Lạt',
      'duration': '4 ngày 3 đêm',
      'activities': 18,
      'meals': 12,
      'people': 2,
      'accommodation': 'Khách sạn Mường Thanh',
      'price': 3500000,
      'rating': 5,
      'imageUrl': 'assets/images/vungtau.png',
    },
    {
      'location': 'Nha Trang',
      'duration': '5 ngày 4 đêm',
      'activities': 20,
      'meals': 15,
      'people': 2,
      'accommodation': 'Vinpearl Resort',
      'price': 5000000,
      'rating': 5,
      'imageUrl': 'assets/images/vungtau.png',
    },
    {
      'location': 'Phú Quốc',
      'duration': '4 ngày 3 đêm',
      'activities': 16,
      'meals': 10,
      'people': 3,
      'accommodation': 'Resort Sunset Sanato',
      'price': 4200000,
      'rating': 4,
      'imageUrl': 'assets/images/vungtau.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedTrips.length,
      itemBuilder: (context, index) {
        final trip = completedTrips[index];
        return _buildTripCard(context, trip);
      },
    );
  }

  Widget _buildTripCard(BuildContext context, Map<String, dynamic> trip) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Color(MyColor.pr3)),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1.5,
      color: Color(MyColor.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/logo_avt.svg',
                  width: 28,
                  height: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${trip['location']} ${trip['duration']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            child: Image.asset(
              trip['imageUrl'],
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: double.infinity,
            color: Color(MyColor.pr2),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildInfoRow('Hoạt động', '${trip['activities']}', 'Nơi ở', trip['accommodation']),
                const SizedBox(height: 6),
                _buildInfoRow('Bữa ăn', '${trip['meals']}', 'Chi phí', '${trip['price']}đ'),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailText('Số người', '${trip['people']}'),
                    Row(
                      children: [
                        const Text('Đánh giá địa điểm: ',
                            style: TextStyle(fontSize: 14, color: Colors.black)),
                        _buildRatingStars(trip['rating']),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(MyColor.pr3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Xem chi tiết'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label1, String value1, String label2, String value2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDetailText(label1, value1),
        _buildDetailText(label2, value2),
      ],
    );
  }

  Widget _buildDetailText(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 14, color: Colors.black87)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 16,
          color: index < rating ? Colors.amber : Color(MyColor.grey),
        ),
      ),
    );
  }
}
