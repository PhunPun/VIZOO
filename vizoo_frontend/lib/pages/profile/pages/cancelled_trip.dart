import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/pages/timeline/timeline_page.dart';
import 'package:vizoo_frontend/pages/profile/widgets/trip_reviews_card.dart';
import '../widgets/trip_data_service.dart'; // Import service mới

class CancelledTripsScreen extends StatelessWidget {
  const CancelledTripsScreen({super.key});

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
          'Chuyến đi đã hủy',
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
      body: const CancelledTripsList(),
    );
  }
}

class CancelledTripsList extends StatefulWidget {
  const CancelledTripsList({super.key});

  @override
  State<CancelledTripsList> createState() => _CancelledTripsListState();
}

class _CancelledTripsListState extends State<CancelledTripsList> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _cancelledTrips = [];
  String _errorMessage = '';
  final TripDataService _tripService = TripDataService(); // Sử dụng service mới

  @override
  void initState() {
    super.initState();
    _loadCancelledTrips();
  }

  Future<void> _loadCancelledTrips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Sử dụng service mới để lấy dữ liệu
      final trips = await _tripService.getUserTrips(tripStatus: 2);

      setState(() {
        _cancelledTrips = trips;
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

    if (_cancelledTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/complain.png', height: 120),
            const SizedBox(height: 16),
            const Text(
              'Bạn chưa có chuyến đi nào đã hủy',
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
      onRefresh: _loadCancelledTrips,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cancelledTrips.length,
        itemBuilder: (context, index) {
          final trip = _cancelledTrips[index];
          return _buildCancelledTripCard(context, trip);
        },
      ),
    );
  }

  Widget _buildCancelledTripCard(
    BuildContext context,
    Map<String, dynamic> trip,
  ) {
    // Create action buttons
    final List<Widget> actionButtons = [
      ElevatedButton(
        onPressed: () {
          // Tạo lại chuyến đi
          _recreateTrip(context, trip);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(MyColor.white),
          foregroundColor: Color(MyColor.pr5),
          side: BorderSide(color: Color(MyColor.pr5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Tạo lại'),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TimelinePage(
                    tripId: trip['trip_id'],
                    locationId: trip['location_id'],
                  ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(MyColor.pr3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Xem chi tiết'),
      ),
    ];

    // Create extra content with cancelled date
    final Widget extraContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.event_busy, color: Colors.red.shade300, size: 16),
          const SizedBox(width: 4),
          Text(
            'Đã hủy vào ngày: ${trip['cancelled_date']}',
            style: TextStyle(
              color: Colors.red.shade700,
              fontStyle: FontStyle.italic,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );

    // Use TripDisplayCard component
    return TripDisplayCard(
      trip: trip,
      statusText: 'Đã hủy',
      statusColor: Colors.red,
      borderColor: Colors.red.shade300,
      actionButtons: actionButtons,
      extraContent: extraContent,
    );
  }

  // Hàm tạo lại chuyến đi
  Future<void> _recreateTrip(
    BuildContext context,
    Map<String, dynamic> trip,
  ) async {
    bool confirm =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Tạo lại chuyến đi'),
                content: const Text('Bạn có muốn tạo lại chuyến đi này không?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Hủy'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Tạo lại'),
                  ),
                ],
              ),
        ) ??
        false;

    if (!confirm) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Cập nhật trạng thái chuyến đi từ "đã hủy" sang "đang áp dụng"
      await FirebaseFirestore.instance
          .collection('user_trip')
          .doc(trip['userTripDocId'])
          .update({
            'check': 0, // 0: đang áp dụng
            'updated_at': Timestamp.now(),
          });

      // Close loading dialog
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tạo lại chuyến đi thành công')),
      );

      // Chuyển đến trang timeline của chuyến đi
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => TimelinePage(
                tripId: trip['trip_id'],
                locationId: trip['location_id'],
              ),
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      print('Error recreating trip: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }
}
