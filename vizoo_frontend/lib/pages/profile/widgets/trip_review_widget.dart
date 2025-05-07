import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/pages/profile/widgets/trip_reviews_card.dart';
import 'package:vizoo_frontend/pages/profile/pages/edit_reviews_screen.dart';
import '../pages/other_reviews_screen.dart';

class TripReviewWidget extends StatefulWidget {
  final String tripId;
  final String reviewId;
  final bool showOtherReviews;

  const TripReviewWidget({
    super.key,
    required this.tripId,
    required this.reviewId,
    this.showOtherReviews = false,
  });

  @override
  State<TripReviewWidget> createState() => _TripReviewWidgetState();
}

class _TripReviewWidgetState extends State<TripReviewWidget> {
  bool _isLoading = true;
  Map<String, dynamic> _reviewData = {};
  Map<String, dynamic> _tripData = {};
  Map<String, dynamic> _locationData = {};
  String _seTripId = '';
  String _locationId = '';
  double _averageRating = 0.0;
  int _totalReviews = 0;
  
  @override
  void initState() {
    super.initState();
    _loadReviewData();
  }

  Future<void> _loadReviewData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      // Step 1: Load review data
      final reviewDoc = await FirebaseFirestore.instance
          .collection('reviews')
          .doc(widget.reviewId)
          .get();
      
      if (!reviewDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đánh giá không tồn tại hoặc đã bị xóa')),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      final reviewData = reviewDoc.data() ?? {};
      reviewData['id'] = reviewDoc.id;
      
      // Step 2: Extract trip ID
      final String tripId = reviewData['trip_id'] as String? ?? widget.tripId;
      
      if (tripId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy mã chuyến đi')),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      // Step 3: Try to extract location_id from trip_id
      if (tripId.contains('_')) {
        final parts = tripId.split('_');
        if (parts.length > 1) {
          _locationId = parts[0];
        }
      }

      // Step 4: If we still don't have location_id, try to find it from review data
      if (_locationId.isEmpty && reviewData.containsKey('location_id')) {
        _locationId = reviewData['location_id'] as String? ?? '';
      }

      // Step 5: Get user's selected_trip data for this trip if available
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      Map<String, dynamic> selectedTripData = {};
      
      if (currentUserId != null) {
        // First check if we have a direct user_trip record to get se_trip_id
        final userTripDocs = await FirebaseFirestore.instance
            .collection('user_trip')
            .where('user_id', isEqualTo: currentUserId)
            .where('trip_id', isEqualTo: tripId)
            .limit(1)
            .get();
            
        if (userTripDocs.docs.isNotEmpty) {
          final userTripData = userTripDocs.docs.first.data();
          _seTripId = userTripData['se_trip_id'] as String? ?? '';
        }
        
        // If we have se_trip_id, get data from selected_trips
        if (_seTripId.isNotEmpty) {
          final seTripDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .collection('selected_trips')
              .doc(_seTripId)
              .get();
              
          if (seTripDoc.exists) {
            selectedTripData = seTripDoc.data() ?? {};
          }
        } else {
          // Try to use the tripId directly as the selected_trip document ID
          final directSeTripDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .collection('selected_trips')
              .doc(tripId)
              .get();
              
          if (directSeTripDoc.exists) {
            selectedTripData = directSeTripDoc.data() ?? {};
            _seTripId = tripId;
          }
        }
      }

      // Step 6: Get location data
      Map<String, dynamic> locationData = {};
      if (_locationId.isNotEmpty) {
        final locationDoc = await FirebaseFirestore.instance
            .collection('dia_diem')
            .doc(_locationId)
            .get();
            
        if (locationDoc.exists) {
          locationData = locationDoc.data() ?? {};
          locationData['id'] = locationDoc.id;
        }
      }
      
      // If we still don't have location data, search for it
      if (locationData.isEmpty) {
        final locationsSnapshot = await FirebaseFirestore.instance.collection('dia_diem').get();
        
        for (var locDoc in locationsSnapshot.docs) {
          final tripCheck = await FirebaseFirestore.instance
              .collection('dia_diem')
              .doc(locDoc.id)
              .collection('trips')
              .doc(tripId)
              .get();
              
          if (tripCheck.exists) {
            _locationId = locDoc.id;
            locationData = locDoc.data();
            locationData['id'] = locDoc.id;
            break;
          }
        }
      }

      // Step 7: Get master trip data (from dia_diem/locationId/trips/tripId)
      Map<String, dynamic> masterTripData = {};
      if (_locationId.isNotEmpty) {
        final tripDoc = await FirebaseFirestore.instance
            .collection('dia_diem')
            .doc(_locationId)
            .collection('trips')
            .doc(tripId)
            .get();
            
        if (tripDoc.exists) {
          masterTripData = tripDoc.data() ?? {};
        }
      }

      // Step 8: Merge data with priority: selectedTripData > masterTripData
      Map<String, dynamic> mergedTripData = {...masterTripData, ...selectedTripData};

      // Step 9: Count activities and meals from selected_trip if available
      int activities = 0;
      int meals = 0;
      
      if (_seTripId.isNotEmpty && currentUserId != null) {
        // First check if metadata already has counts
        activities = selectedTripData['so_act'] is int
            ? selectedTripData['so_act']
            : int.tryParse(selectedTripData['so_act']?.toString() ?? '0') ?? 0;
            
        meals = selectedTripData['so_eat'] is int
            ? selectedTripData['so_eat']
            : int.tryParse(selectedTripData['so_eat']?.toString() ?? '0') ?? 0;
            
        // If counts are 0, manually count from timelines
        if (activities == 0 || meals == 0) {
          final timelinesSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .collection('selected_trips')
              .doc(_seTripId)
              .collection('timelines')
              .get();
              
          int actCount = 0;
          int mealCount = 0;
          
          for (var timeline in timelinesSnapshot.docs) {
            final scheduleSnapshot = await timeline.reference.collection('schedule').get();
            
            actCount += scheduleSnapshot.docs.length;
            
            for (var schedule in scheduleSnapshot.docs) {
              final actId = schedule.data()['act_id'] as String?;
              if (actId == null || actId.isEmpty) continue;
              
              final activityDoc = await FirebaseFirestore.instance
                  .collection('dia_diem')
                  .doc(_locationId)
                  .collection('activities')
                  .doc(actId)
                  .get();
                  
              if (activityDoc.exists && activityDoc.data()?['categories'] == 'eat') {
                mealCount++;
              }
            }
          }
          
          // Update counts if we found some
          if (actCount > 0 && activities == 0) activities = actCount;
          if (mealCount > 0 && meals == 0) meals = mealCount;
          
          // Update the selected_trips document with these counts
          if ((actCount > 0 || mealCount > 0) && currentUserId != null && _seTripId.isNotEmpty) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserId)
                .collection('selected_trips')
                .doc(_seTripId)
                .update({
                  'so_act': actCount > 0 ? actCount : FieldValue.delete(),
                  'so_eat': mealCount > 0 ? mealCount : FieldValue.delete(),
                });
          }
        }
      }
      
      // If still 0, try to get from mergedTripData
      if (activities == 0 && mergedTripData.containsKey('so_act')) {
        activities = mergedTripData['so_act'] is int
            ? mergedTripData['so_act']
            : int.tryParse(mergedTripData['so_act']?.toString() ?? '0') ?? 0;
      }
      
      if (meals == 0 && mergedTripData.containsKey('so_eat')) {
        meals = mergedTripData['so_eat'] is int
            ? mergedTripData['so_eat']
            : int.tryParse(mergedTripData['so_eat']?.toString() ?? '0') ?? 0;
      }

      // Step 10: Get rating info
      // Calculate average rating and count total reviews
      final reviewsSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('trip_id', isEqualTo: tripId)
          .get();
          
      double totalRating = 0;
      int totalValidReviews = 0;
      
      for (var doc in reviewsSnapshot.docs) {
        final votes = doc.data()['votes'];
        if (votes != null) {
          double rating = 0;
          if (votes is int) {
            rating = votes.toDouble();
          } else if (votes is String) {
            rating = double.tryParse(votes) ?? 0;
          } else {
            rating = double.tryParse(votes.toString()) ?? 0;
          }
          
          if (rating > 0) {
            totalRating += rating;
            totalValidReviews++;
          }
        }
      }
      
      double averageRating = totalValidReviews > 0 ? totalRating / totalValidReviews : 0;

      // Step 11: Find best image - priority: selected_trip > master trip > location
      String imageUrl = 'assets/images/vungtau.png';  // Default fallback
      
      if (selectedTripData.containsKey('anh') && 
          selectedTripData['anh'] != null && 
          selectedTripData['anh'].toString().isNotEmpty) {
        imageUrl = selectedTripData['anh'].toString();
      } else if (masterTripData.containsKey('anh') && 
                masterTripData['anh'] != null && 
                masterTripData['anh'].toString().isNotEmpty) {
        imageUrl = masterTripData['anh'].toString();
      } else if (locationData.containsKey('hinh_anh1') && 
                locationData['hinh_anh1'] != null && 
                locationData['hinh_anh1'].toString().isNotEmpty) {
        imageUrl = locationData['hinh_anh1'].toString();
      }

      // Step 12: Update state with all our collected data
      if (mounted) {
        setState(() {
          _reviewData = reviewData;
          _tripData = mergedTripData;
          _locationData = locationData;
          _averageRating = averageRating;
          _totalReviews = totalValidReviews;
          _isLoading = false;
          
          // Update tripData with our counted values if they're better
          if (activities > 0) _tripData['so_act'] = activities;
          if (meals > 0) _tripData['so_eat'] = meals;
          if (imageUrl.isNotEmpty) _tripData['anh'] = imageUrl;
        });
      }
    } catch (e) {
      print('Lỗi khi tải dữ liệu đánh giá: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteReview() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa đánh giá này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy', style: TextStyle(color: Color(MyColor.pr3))),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Color(MyColor.pr5))),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(widget.reviewId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa đánh giá thành công')),
        );
        Navigator.pop(context, true); // Trở về kèm kết quả thành công
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa đánh giá: $e')),
        );
      }
    }
  }

  String _formatRating(int rating) {
    switch (rating) {
      case 5:
        return 'Tuyệt vời';
      case 4:
        return 'Rất tốt';
      case 3:
        return 'Tốt';
      case 2:
        return 'Tạm được';
      case 1:
        return 'Tệ';
      default:
        return '';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Handle case when no data is available
    if (_reviewData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không tìm thấy dữ liệu đánh giá',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Quay lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(MyColor.pr3),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Extract data for display
    final rating = _reviewData['votes'] ?? 0;
    final int ratingValue = rating is int ? rating : int.tryParse(rating.toString()) ?? 0;
    final comment = _reviewData['comment'] ?? '';
    
    // Number of days in the trip
    final soNgay = _tripData['so_ngay'] is int
        ? _tripData['so_ngay']
        : int.tryParse(_tripData['so_ngay']?.toString() ?? '1') ?? 1;
        
    // Get activity and meal counts
    final activities = _tripData.containsKey('so_act')
        ? (_tripData['so_act'] is int
            ? _tripData['so_act']
            : int.tryParse(_tripData['so_act']?.toString() ?? '0') ?? 0)
        : 0;
        
    final meals = _tripData.containsKey('so_eat')
        ? (_tripData['so_eat'] is int
            ? _tripData['so_eat']
            : int.tryParse(_tripData['so_eat']?.toString() ?? '0') ?? 0)
        : 0;
        
    // Get accommodation and price
    final accommodation = _tripData['noi_o'] ?? 'Không xác định';
    final price = _tripData['chi_phi'] is int
        ? _tripData['chi_phi']
        : int.tryParse(_tripData['chi_phi']?.toString() ?? '0') ?? 0;
        
    // People count
    final people = _tripData['so_nguoi'] is int
        ? _tripData['so_nguoi']
        : int.tryParse(_tripData['so_nguoi']?.toString() ?? '1') ?? 1;

    // Extract image URL
    final imageUrl = _tripData['anh'] ?? 
                     _locationData['hinh_anh1'] ?? 
                     'assets/images/vungtau.png';

    // Prepare trip info for the TripDisplayCard
    final Map<String, dynamic> tripReviewInfo = {
      'id': _reviewData['id'],
      'trip_id': _reviewData['trip_id'],
      'location_id': _locationId,
      'se_trip_id': _seTripId,
      'location': _locationData['ten'] ?? 'Không xác định',
      'duration': '$soNgay ngày ${soNgay > 1 ? (soNgay - 1) : 0} đêm',
      'rating': ratingValue,
      'comment': comment,
      'imageUrl': imageUrl,
      'accommodation': accommodation,
      'price': price,
      'people': people,
      'activities': activities,
      'meals': meals,
      'averageRating': _averageRating,
      'totalReviews': _totalReviews,
    };

    // Action buttons
    final List<Widget> actionButtons = [
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditReviewScreen(
                review: tripReviewInfo,
                isNewReview: false,
              ),
            ),
          ).then((result) {
            if (result == true) {
              _loadReviewData();
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(MyColor.white),
          foregroundColor: Color(MyColor.pr5),
          side: BorderSide(color: Color(MyColor.pr5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Chỉnh sửa'),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: _deleteReview,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(MyColor.pr3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Xóa'),
      ),
    ];

    // Extra content with rating and review
    final Widget extraContent = Column(
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
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              index < ratingValue ? Icons.star : Icons.star_border,
              color: index < ratingValue ? Colors.amber : Colors.grey,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              _formatRating(ratingValue),
              style: TextStyle(
                color: Color(MyColor.pr5),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
          comment,
          style: const TextStyle(fontSize: 14, color: Color(MyColor.black)),
        ),
        const SizedBox(height: 12),
        
        // Show average rating if there are multiple reviews
        if (_totalReviews > 1)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Đánh giá trung bình: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${_averageRating.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: Color(MyColor.pr5),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '($_totalReviews đánh giá)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Button to view other reviews
              if (widget.showOtherReviews)
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtherReviewsScreen(
                          tripId: tripReviewInfo['trip_id'],
                          locationName: tripReviewInfo['location'],
                          tripDuration: tripReviewInfo['duration'],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.reviews, size: 16),
                  label: const Text('Xem đánh giá khác'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: Color(MyColor.pr4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
      ],
    );

    // Display the review card using the existing TripDisplayCard widget
    return TripDisplayCard(
      trip: tripReviewInfo,
      statusText: 'Đã đánh giá',
      statusColor: Color(MyColor.pr5),
      borderColor: Color(MyColor.pr3),
      actionButtons: actionButtons,
      extraContent: extraContent,
    );
  }
}