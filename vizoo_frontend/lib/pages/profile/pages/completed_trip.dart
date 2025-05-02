import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/pages/timeline/timeline_page.dart';
import 'package:vizoo_frontend/pages/profile/pages/edit_reviews_screen.dart';
import 'package:vizoo_frontend/pages/profile/widgets/trip_reviews_card.dart';

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
      final trips = await _fetchCompletedTrips();
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

  Future<List<Map<String, dynamic>>> _fetchCompletedTrips() async {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) return [];

    try {
      print('Fetching completed trips for user: $currentUserId');
      
      // Get all completed trips (check = 1) for current user
      final userTripsSnapshot = await FirebaseFirestore.instance
          .collection('user_trip')
          .where('user_id', isEqualTo: currentUserId)
          .where('check', isEqualTo: 1) // Completed
          .orderBy('updated_at', descending: true)
          .get();

      print('Found ${userTripsSnapshot.docs.length} completed trips');

      // Store results here
      List<Map<String, dynamic>> completedTrips = [];
      
      // Get all locations in one query to improve performance
      final locationsSnapshot = await FirebaseFirestore.instance
          .collection('dia_diem')
          .get();
      
      // Create a map of location data for faster lookup
      Map<String, Map<String, dynamic>> locationsMap = {};
      for (var doc in locationsSnapshot.docs) {
        locationsMap[doc.id] = {...doc.data(), 'id': doc.id};
      }
      
      // Get all reviews for this user in one query
      final reviewsSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('user_id', isEqualTo: currentUserId)
          .get();
          
      // Create a map of reviews by trip_id for faster lookup
      Map<String, Map<String, dynamic>> reviewsMap = {};
      for (var doc in reviewsSnapshot.docs) {
        final data = doc.data();
        final tripId = data['trip_id'] as String? ?? '';
        if (tripId.isNotEmpty) {
          reviewsMap[tripId] = {...data, 'id': doc.id};
        }
      }

      // Process each user trip
      for (var userTripDoc in userTripsSnapshot.docs) {
        final data = userTripDoc.data();
        final String tripId = data['trip_id'] as String? ?? '';
        if (tripId.isEmpty) continue;

        print('Processing completed trip: $tripId');

        // Extract locationId from tripId (format is usually locationId_tripInfo)
        String locationId = '';
        final parts = tripId.split('_');
        if (parts.length > 1) {
          locationId = parts[0];
        }
        
        // If we couldn't extract a locationId, search through all locations
        DocumentSnapshot? tripSnapshot;
        try {
          if (locationId.isNotEmpty && locationsMap.containsKey(locationId)) {
            tripSnapshot = await FirebaseFirestore.instance
                .collection('dia_diem')
                .doc(locationId)
                .collection('trips')
                .doc(tripId)
                .get();
          } 
          
          // If trip not found or location ID not determined, search all locations
          if (tripSnapshot == null || !tripSnapshot.exists) {
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
        } catch (e) {
          print('Error finding trip location: $e');
          continue;
        }
        
        // If we found the trip data
        if (tripSnapshot != null && tripSnapshot.exists) {
          final tripData = tripSnapshot.data() as Map<String, dynamic>? ?? {};
          final locationData = locationsMap[locationId] ?? {};
          
          // Find review for this trip
          int rating = 0;
          String reviewId = '';
          String reviewComment = '';
          if (reviewsMap.containsKey(tripId)) {
            final reviewData = reviewsMap[tripId]!;
            reviewId = reviewData['id'];
            reviewComment = reviewData['comment'] as String? ?? '';
            
            // Parse rating properly
            final votesData = reviewData['votes'];
            if (votesData != null) {
              if (votesData is String) {
                rating = int.tryParse(votesData) ?? 0;
              } else if (votesData is int) {
                rating = votesData;
              } else if (votesData is double) {
                rating = votesData.toInt();
              } else {
                rating = int.tryParse(votesData.toString()) ?? 0;
              }
            }
          }
          
          // Format completion date
          String completionDate = 'Không xác định';
          if (data.containsKey('updated_at') && data['updated_at'] is Timestamp) {
            final timestamp = data['updated_at'] as Timestamp;
            final date = timestamp.toDate();
            completionDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
          Map<String, dynamic> completedTrip = {
            'trip_id': tripId,
            'location_id': locationId,
            'location': locationData['ten'] ?? 'Không xác định',
            'duration': '$soDays ngày ${soDays > 1 ? (soDays - 1) : 0} đêm',
            'activities': activities,
            'meals': meals,
            'people': people,
            'accommodation': tripData['noi_o'] ?? 'Không xác định',
            'price': price,
            'rating': rating,
            'review_id': reviewId,
            'comment': reviewComment,
            'imageUrl': locationData['hinh_anh1'] ?? tripData['anh'] ?? 'assets/images/vungtau.png',
            'completion_date': completionDate,
            'userTripDocId': userTripDoc.id,
          };

          completedTrips.add(completedTrip);
          print('Added completed trip: ${locationData['ten']} $soDays ngày');
        } else {
          print('Trip not found: $tripId');
        }
      }

      print('Total completed trips: ${completedTrips.length}');
      return completedTrips;
    } catch (e) {
      print('Error fetching completed trips: $e');
      throw Exception('Không thể tải chuyến đi đã hoàn thành: $e');
    }
  }

  Widget _buildCompletedTripCard(
    BuildContext context,
    Map<String, dynamic> trip,
  ) {
    // Create action buttons
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

    // Create extra content for rating and completion date
    Widget extraContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Always show completion date
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
        
        // Show rating if it exists
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

    // Use TripDisplayCard component
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
    final reviewData = {
      'trip_id': trip['trip_id'],
      'location_id': trip['location_id'],
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
      // Refresh when returning
      if (result == true) {
        _loadCompletedTrips();
      }
    });
  }

  void _navigateToEditReview(BuildContext context, Map<String, dynamic> trip) {
    final reviewData = {
      'id': trip['review_id'],
      'trip_id': trip['trip_id'],
      'location_id': trip['location_id'],
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
      // Refresh when returning
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