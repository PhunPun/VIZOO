import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/pages/timeline/timeline_page.dart';
import 'package:vizoo_frontend/pages/profile/widgets/trip_reviews_card.dart';
import '../widgets/trip_data_service.dart';

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
  final TripDataService _tripService = TripDataService(); // Sử dụng service đã cải tiến

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
      // Sử dụng service đã cải tiến để lấy dữ liệu
      final trips = await _tripService.getUserTrips(tripStatus: 2);
      
      // Đảm bảo cập nhật số lượng hoạt động và bữa ăn cho mỗi chuyến đi
      for (var trip in trips) {
        if (trip.containsKey('se_trip_id') && trip['se_trip_id'].toString().isNotEmpty) {
          await _tripService.updateActivityAndMealCounts(trip['se_trip_id']);
        }
      }
      
      // Tải lại dữ liệu đã cập nhật
      final updatedTrips = await _tripService.getUserTrips(tripStatus: 2);

      setState(() {
        _cancelledTrips = updatedTrips;
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
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
    ) ?? false;

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

      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (currentUserId.isEmpty) {
        throw Exception("Người dùng chưa đăng nhập");
      }

      // Lấy dữ liệu gốc từ chuyến đi đã hủy
      final originalTripId = trip['trip_id'];
      final locationId = trip['location_id'];
      final seTripId = trip['se_trip_id'];

      if (seTripId.isEmpty || originalTripId.isEmpty || locationId.isEmpty) {
        throw Exception("Thiếu thông tin cần thiết để tạo lại chuyến đi");
      }

      // 1. Đọc dữ liệu từ selected_trip gốc nếu có
      DocumentSnapshot<Map<String, dynamic>>? originalSeTrip;
      
      if (seTripId.isNotEmpty) {
        originalSeTrip = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('selected_trips')
            .doc(seTripId)
            .get();
      }

      // 2. Tạo selected_trip mới với trạng thái "đang áp dụng"
      final newSeTripRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('selected_trips')
          .doc(); // Tạo ID mới

      final now = Timestamp.now();
      
      final baseData = {
        'trip_id': originalTripId,
        'location_id': locationId,
        'check': 0, // 0: đang áp dụng
        'status': true,
        'created_at': now,
        'updated_at': now,
      };
      
      // Kết hợp với dữ liệu gốc nếu có
      Map<String, dynamic> combinedData = {...baseData};
      if (originalSeTrip != null && originalSeTrip.exists) {
        final originalData = originalSeTrip.data();
        if (originalData != null) {
          // Lấy các trường hữu ích từ bản ghi gốc
          final fieldsToKeep = [
            'so_act', 'so_eat', 'so_nguoi', 'chi_phi', 'noi_o', 'anh', 'so_ngay'
          ];
          
          for (var field in fieldsToKeep) {
            if (originalData.containsKey(field)) {
              combinedData[field] = originalData[field];
            }
          }
        }
      }
      
      // Ghi dữ liệu mới
      await newSeTripRef.set(combinedData);
      
      // 3. Sao chép timelines và schedule từ selected_trip gốc (nếu có) hoặc từ master
      await _copyTimelinesAndSchedules(
        currentUserId, 
        locationId, 
        originalTripId, 
        seTripId, 
        newSeTripRef.id
      );

      // 4. Cập nhật user_trip
      await FirebaseFirestore.instance
          .collection('user_trip')
          .doc(trip['userTripDocId'])
          .update({
            'check': 0, // 0: đang áp dụng
            'se_trip_id': newSeTripRef.id,
            'updated_at': now,
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
          builder: (context) => TimelinePage(
            tripId: originalTripId,
            locationId: locationId,
            se_tripId: newSeTripRef.id,
          ),
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      print('Error recreating trip: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }
  
  // Hàm hỗ trợ sao chép timelines và schedules
  Future<void> _copyTimelinesAndSchedules(
    String userId,
    String locationId,
    String tripId,
    String oldSeTripId,
    String newSeTripId
  ) async {
    try {
      // 1. Thử sao chép từ selected_trip cũ nếu có
      if (oldSeTripId.isNotEmpty) {
        final oldSeTripRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('selected_trips')
            .doc(oldSeTripId);
        
        final newSeTripRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('selected_trips')
            .doc(newSeTripId);
            
        final timelineSnapshot = await oldSeTripRef.collection('timelines').get();
        
        if (timelineSnapshot.docs.isNotEmpty) {
          print('Sao chép ${timelineSnapshot.docs.length} timelines từ selected_trip cũ');
          
          for (final timelineDoc in timelineSnapshot.docs) {
            // Sao chép timeline
            final newTimelineRef = newSeTripRef.collection('timelines').doc(timelineDoc.id);
            await newTimelineRef.set({
              ...timelineDoc.data(),
              'location_id': locationId
            });
            
            // Sao chép schedule trong timeline
            final scheduleSnapshot = await timelineDoc.reference.collection('schedule').get();
            for (final scheduleDoc in scheduleSnapshot.docs) {
              await newTimelineRef.collection('schedule').doc(scheduleDoc.id).set({
                ...scheduleDoc.data(),
                'location_id': locationId,
                'status': false  // Reset trạng thái hoàn thành
              });
            }
          }
          return; // Đã sao chép thành công từ selected_trip cũ
        }
      }
      
      // 2. Nếu không thể sao chép từ selected_trip cũ, sao chép từ master trip
      print('Sao chép dữ liệu từ master trip');
      final masterTripRef = FirebaseFirestore.instance
          .collection('dia_diem')
          .doc(locationId)
          .collection('trips')
          .doc(tripId);
          
      final newSeTripRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('selected_trips')
          .doc(newSeTripId);
          
      final timelineSnapshot = await masterTripRef.collection('timelines').get();
      
      for (final timelineDoc in timelineSnapshot.docs) {
        // Sao chép timeline
        final newTimelineRef = newSeTripRef.collection('timelines').doc(timelineDoc.id);
        await newTimelineRef.set({
          ...timelineDoc.data(),
          'location_id': locationId
        });
        
        // Sao chép schedule trong timeline
        final scheduleSnapshot = await timelineDoc.reference.collection('schedule').get();
        for (final scheduleDoc in scheduleSnapshot.docs) {
          await newTimelineRef.collection('schedule').doc(scheduleDoc.id).set({
            ...scheduleDoc.data(),
            'location_id': locationId,
            'status': false  // Đặt trạng thái ban đầu là chưa hoàn thành
          });
        }
      }
    } catch (e) {
      print('Lỗi khi sao chép timelines và schedules: $e');
      throw e;
    }
  }
}