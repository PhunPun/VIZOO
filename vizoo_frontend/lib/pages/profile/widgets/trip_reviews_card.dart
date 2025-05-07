import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/pages/timeline/timeline_page.dart';

class TripDisplayCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  final String statusText;
  final Color statusColor;
  final Color borderColor;
  final List<Widget> actionButtons;
  final Widget? extraContent; // Custom additional content

  const TripDisplayCard({
    super.key,
    required this.trip,
    required this.statusText,
    required this.statusColor,
    required this.borderColor,
    required this.actionButtons,
    this.extraContent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: Color(MyColor.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with location and status
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
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Trip image with overlay info
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TimelinePage(
                        tripId: trip['trip_id'],
                        locationId: trip['location_id'],
                        se_tripId: trip['se_trip_id'],
                      ),
                ),
              );
            },
            child: Stack(
              children: [
                // Main image
                Hero(
                  tag: 'trip_image_${trip['trip_id']}',
                  child: ClipRRect(child: _buildImage(trip)),
                ),

                // Overlay with trip details
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.bed, size: 16, color: Colors.white),
                                const SizedBox(width: 4),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 150),
                                  child: Text(
                                    trip['accommodation'] ?? 'Không xác định',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_walk,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${trip['activities'] ?? 0} hoạt động',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.restaurant,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${trip['meals'] ?? 0} bữa ăn',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.attach_money,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${NumberFormat('#,###', 'vi_VN').format(trip['price'] ?? 0)}đ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Rating badge (if exists)
                if (trip.containsKey('rating') && trip['rating'] > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${trip['rating']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Trip details
          Container(
            width: double.infinity,
            color: Color(MyColor.pr2),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildInfoRow(
                  'Hoạt động',
                  '${trip['activities']}',
                  'Nơi ở',
                  trip['accommodation'],
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  'Bữa ăn',
                  '${trip['meals']}',
                  'Chi phí',
                  '${NumberFormat('#,###', 'vi_VN').format(trip['price'] ?? 0)}đ',
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailText('Số người', '${trip['people']}'),
                    trip.containsKey('start_date')
                        ? _buildDetailText('Ngày bắt đầu', trip['start_date'])
                        : (trip.containsKey('completion_date')
                            ? _buildDetailText(
                              'Hoàn thành',
                              trip['completion_date'],
                            )
                            : (trip.containsKey('cancelled_date')
                                ? _buildDetailText(
                                  'Đã hủy',
                                  trip['cancelled_date'],
                                )
                                : const SizedBox())),
                  ],
                ),
                const SizedBox(height: 12),

                // Extra content if provided
                if (extraContent != null) extraContent!,

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actionButtons,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDetailText(label1, value1),
        _buildDetailText(label2, value2, isLongText: true),
      ],
    );
  }

  Widget _buildDetailText(
    String label,
    String value, {
    bool isLongText = false,
  }) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        isLongText
            ? ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 120),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            )
            : Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
      ],
    );
  }

  Widget _buildImage(Map<String, dynamic> trip) {
    final String imageUrl = trip['imageUrl']?.toString() ?? '';

    if (imageUrl.isEmpty) {
      return _buildDefaultImage();
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Lỗi tải ảnh network: $error');
          return _buildDefaultImage();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 150,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                valueColor: AlwaysStoppedAnimation<Color>(Color(MyColor.pr5)),
              ),
            ),
          );
        },
      );
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Lỗi tải ảnh asset: $error');
          return _buildDefaultImage();
        },
      );
    } else {
      return _buildDefaultImage();
    }
  }

  Widget _buildDefaultImage() {
    return Container(
      height: 150,
      color: Colors.grey[300],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Không có hình ảnh',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
