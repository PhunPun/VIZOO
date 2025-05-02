import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/pages/timeline/timeline_page.dart';
import 'package:vizoo_frontend/pages/profile/widgets/trip_reviews_card.dart';

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
            child: SvgPicture.asset(
              'assets/icons/logo.svg',
            ),
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
      final trips = await _fetchCancelledTrips();
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

  Future<List<Map<String, dynamic>>> _fetchCancelledTrips() async {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) return [];

    try {
      print('Fetching cancelled trips for user: $currentUserId');
      
      // Get all cancelled trips (check = 2) for current user
      final userTripsSnapshot = await FirebaseFirestore.instance
          .collection('user_trip')
          .where('user_id', isEqualTo: currentUserId)
          .where('check', isEqualTo: 2) // Cancelled
          .orderBy('updated_at', descending: true)
          .get();

      print('Found ${userTripsSnapshot.docs.length} cancelled trips');

      // Store results here
      List<Map<String, dynamic>> cancelledTrips = [];
      
      // Get all locations in one query to improve performance
      final locationsSnapshot = await FirebaseFirestore.instance
          .collection('dia_diem')
          .get();
      
      // Create a map of location data for faster lookup
      Map<String, Map<String, dynamic>> locationsMap = {};
      for (var doc in locationsSnapshot.docs) {
        locationsMap[doc.id] = {...doc.data(), 'id': doc.id};
      }

      // Process each user trip
      for (var userTripDoc in userTripsSnapshot.docs) {
        final data = userTripDoc.data();
        final String tripId = data['trip_id'] as String? ?? '';
        if (tripId.isEmpty) continue;

        print('Processing cancelled trip: $tripId');

        // Extract locationId from tripId (format is usually locationId_tripInfo)
        String locationId = '';
        final parts = tripId.split('_');
        if (parts.length > 1) {
          locationId = parts[0];
        }
        
        // If we couldn't extract a locationId, search through all locations
        DocumentSnapshot? tripSnapshot;
        if (locationId.isNotEmpty && locationsMap.containsKey(locationId)) {
          tripSnapshot = await FirebaseFirestore.instance
              .collection('dia_diem')
              .doc(locationId)
              .collection('trips')
              .doc(tripId)
              .get();
        } else {
          // If we can't determine the location, check all locations
          for (var locId in locationsMap.keys) {
            final tempSnapshot = await FirebaseFirestore.instance
                .collection('dia_diem')
                .doc(locId)
                .collection('trips')
                .doc(tripId)
                .get();
                
            if (tempSnapshot.exists) {
              tripSnapshot = tempSnapshot;
              locationId = locId;
              print('Found trip in location: $locationId');
              break;
            }
          }
        }
        
        // If we found the trip data
        if (tripSnapshot != null && tripSnapshot.exists) {
          final tripData = tripSnapshot.data() as Map<String, dynamic>? ?? {};
          final locationData = locationsMap[locationId] ?? {};
          
          // Format cancellation date
          String cancelledDate = 'Không xác định';
          if (data.containsKey('updated_at') && data['updated_at'] is Timestamp) {
            final timestamp = data['updated_at'] as Timestamp;
            final date = timestamp.toDate();
            cancelledDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
          }
          
          // Safely get trip day count
          int soDays = 0;
          if (tripData.containsKey('so_ngay')) {
            if (tripData['so_ngay'] is int) {
              soDays = tripData['so_ngay'] as int;
            } else if (tripData['so_ngay'] is String) {
              soDays = int.tryParse(tripData['so_ngay'] as String) ?? 0;
            } else if (tripData['so_ngay'] != null) {
              soDays = int.tryParse(tripData['so_ngay'].toString()) ?? 0;
            }
          }

          // Safely get other properties
          final activities = tripData['so_act'] is int ? tripData['so_act'] : int.tryParse(tripData['so_act']?.toString() ?? '0') ?? 0;
          final meals = tripData['so_eat'] is int ? tripData['so_eat'] : int.tryParse(tripData['so_eat']?.toString() ?? '0') ?? 0;
          final people = tripData['so_nguoi'] is int ? tripData['so_nguoi'] : int.tryParse(tripData['so_nguoi']?.toString() ?? '1') ?? 1;
          final price = tripData['chi_phi'] is int ? tripData['chi_phi'] : int.tryParse(tripData['chi_phi']?.toString() ?? '0') ?? 0;
          
          // Create trip object
          Map<String, dynamic> cancelledTrip = {
            'trip_id': tripId,
            'location_id': locationId,
            'location': locationData['ten'] ?? 'Không xác định',
            'duration': '$soDays ngày ${soDays > 1 ? (soDays - 1) : 0} đêm',
            'activities': activities,
            'meals': meals,
            'people': people,
            'accommodation': tripData['noi_o'] ?? 'Không xác định',
            'price': price,
            'imageUrl': locationData['hinh_anh1'] ?? tripData['anh'] ?? 'assets/images/vungtau.png',
            'cancelled_date': cancelledDate,
            'userTripDocId': userTripDoc.id,
          };

          cancelledTrips.add(cancelledTrip);
          print('Added cancelled trip: ${locationData['ten']} $soDays ngày');
        } else {
          print('Trip not found: $tripId');
        }
      }

      print('Total cancelled trips: ${cancelledTrips.length}');
      return cancelledTrips;
    } catch (e) {
      print('Error fetching cancelled trips: $e');
      throw Exception('Không thể tải chuyến đi đã hủy: $e');
    }
  }

  Widget _buildCancelledTripCard(BuildContext context, Map<String, dynamic> trip) {
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Tạo lại'),
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
  Future<void> _recreateTrip(BuildContext context, Map<String, dynamic> trip) async {
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
          return const Center(
            child: CircularProgressIndicator(),
          );
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
          builder: (context) => TimelinePage(
            tripId: trip['trip_id'],
            locationId: trip['location_id'],
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
}