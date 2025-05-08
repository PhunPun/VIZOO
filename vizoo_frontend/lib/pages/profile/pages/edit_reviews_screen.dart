import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import '../widgets/trip_data_service.dart';

class EditReviewScreen extends StatefulWidget {
  final Map<String, dynamic> review;
  final bool isNewReview;
  final String userId;

  const EditReviewScreen({
    super.key,
    required this.review,
    this.isNewReview = false,
    this.userId = '',
  });

  @override
  State<EditReviewScreen> createState() => _EditReviewScreenState();
}

class _EditReviewScreenState extends State<EditReviewScreen> {
  late int selectedRating;
  late TextEditingController commentController;
  bool _isSaving = false;
  bool _isLoading = true;
  final TripDataService _tripService = TripDataService();

  // Trip data
  String _imageUrl = 'assets/images/vungtau.png';
  int _activities = 0;
  int _meals = 0;
  String _location = '';
  String _duration = '';
  String _accommodation = '';
  int _price = 0;
  int _people = 1;
  String _ratingText(int rating) {
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
  void initState() {
    super.initState();
    // Initialize values from review data
    selectedRating = widget.review['rating'] ?? 0;
    commentController = TextEditingController(
      text: widget.review['comment'] ?? '',
    );

    // Load trip details
    _loadTripDetails();
  }

  Future<void> _loadTripDetails() async {
    try {
      setState(() => _isLoading = true);

      // Get basic info from review object
      final tripId = widget.review['trip_id'];
      final seTripId = widget.review['se_trip_id'] ?? '';

      final userId =
          widget.userId.isEmpty
              ? FirebaseAuth.instance.currentUser?.uid
              : widget.userId;

      if (userId == null) {
        throw Exception("Cannot identify user");
      }

      Map<String, dynamic> tripData = {};

      // First, try to get data from selected_trips if seTripId is available
      if (seTripId.isNotEmpty) {
        final seTripDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('selected_trips')
                .doc(seTripId)
                .get();

        if (seTripDoc.exists) {
          tripData = seTripDoc.data() ?? {};
          // Update trip info from selected_trip
          _updateTripInfoFromData(tripData);
        }
      }
      // If no seTripId or couldn't find data, try to find from user_trip
      else if (tripId != null) {
        final userTripDocs =
            await FirebaseFirestore.instance
                .collection('user_trip')
                .where('user_id', isEqualTo: userId)
                .where('trip_id', isEqualTo: tripId)
                .limit(1)
                .get();

        if (userTripDocs.docs.isNotEmpty) {
          final userTripData = userTripDocs.docs.first.data();
          final foundSeTripId = userTripData['se_trip_id'] as String? ?? '';

          if (foundSeTripId.isNotEmpty) {
            final seTripDoc =
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('selected_trips')
                    .doc(foundSeTripId)
                    .get();

            if (seTripDoc.exists) {
              tripData = seTripDoc.data() ?? {};
              _updateTripInfoFromData(tripData);
            }
          }
        }
      }

      // If location is still empty, use data from review
      if (_location.isEmpty || _location == 'Không xác định') {
        _location = widget.review['location'] ?? 'Không xác định';
        _duration = widget.review['duration'] ?? '';
        _accommodation = widget.review['accommodation'] ?? 'Không xác định';
        _price = widget.review['price'] ?? 0;
        _people = widget.review['people'] ?? 1;
        _activities = widget.review['activities'] ?? 0;
        _meals = widget.review['meals'] ?? 0;

        if (widget.review['imageUrl'] != null &&
            widget.review['imageUrl'].toString().isNotEmpty) {
          _imageUrl = widget.review['imageUrl'];
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading trip details: $e');
      setState(() => _isLoading = false);
    }
  }

  void _updateTripInfoFromData(Map<String, dynamic> data) {
    // Update activities and meals count
    _activities = _extractIntValue(data, 'so_act', 0);
    _meals = _extractIntValue(data, 'so_eat', 0);

    // Update image
    if (data.containsKey('anh') &&
        data['anh'] != null &&
        data['anh'].toString().isNotEmpty) {
      _imageUrl = data['anh'].toString();
    }

    // Update other information
    _accommodation = data['noi_o']?.toString() ?? 'Không xác định';
    _price = _extractIntValue(data, 'chi_phi', 0);
    _people = _extractIntValue(data, 'so_nguoi', 1);

    // Handle days information
    if (data.containsKey('so_ngay')) {
      final soDays = _extractIntValue(data, 'so_ngay', 1);
      _duration = '$soDays ngày ${soDays > 1 ? (soDays - 1) : 0} đêm';
    }

    // Get location name
    if (data.containsKey('name')) {
      _location = data['name']?.toString() ?? 'Không xác định';
    }
  }

  // Extract int value from data
  int _extractIntValue(
    Map<String, dynamic> data,
    String key,
    int defaultValue,
  ) {
    if (!data.containsKey(key) || data[key] == null) return defaultValue;

    if (data[key] is int) return data[key];
    return int.tryParse(data[key].toString()) ?? defaultValue;
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> _saveReview() async {
    if (selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao đánh giá')),
      );
      return;
    }

    if (commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập bình luận của bạn')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userId =
          widget.userId.isEmpty
              ? FirebaseAuth.instance.currentUser?.uid
              : widget.userId;

      if (userId == null) {
        throw Exception("User not logged in");
      }

      final String tripId = widget.review['trip_id'] ?? '';
      final String locationId = widget.review['location_id'] ?? '';
      final String seTripId = widget.review['se_trip_id'] ?? '';

      if (tripId.isEmpty) {
        throw Exception("Trip ID is missing");
      }

      // Make sure we're using the correct IDs
      final Map<String, dynamic> reviewData = {
        'user_id': userId,
        'trip_id': tripId,
        'location_id': locationId,
        'se_trip_id': seTripId,
        'comment': commentController.text.trim(),
        'votes': selectedRating,
        'trip_details': {
          'location': widget.review['location'] ?? 'Không xác định',
          'duration': widget.review['duration'] ?? '',
          'accommodation': widget.review['accommodation'] ?? 'Không xác định',
          'price': widget.review['price'] ?? 0,
          'people': widget.review['people'] ?? 1,
          'activities': widget.review['activities'] ?? 0,
          'meals': widget.review['meals'] ?? 0,
          'imageUrl': widget.review['imageUrl'] ?? '',
        },
      };

      if (widget.isNewReview) {
        // Create new review with all necessary fields
        reviewData['created_at'] = Timestamp.now();

        await FirebaseFirestore.instance.collection('reviews').add(reviewData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm đánh giá thành công')),
        );
      } else {
        // Update existing review
        reviewData['updated_at'] = Timestamp.now();

        await FirebaseFirestore.instance
            .collection('reviews')
            .doc(widget.review['id'])
            .update(reviewData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật đánh giá thành công')),
        );
      }

      // Return success
      Navigator.pop(context, true);
    } catch (e) {
      print('Error saving review: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã xảy ra lỗi: $e')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(MyColor.white),
      appBar: AppBar(
        backgroundColor: Color(MyColor.white),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(MyColor.black)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$_location $_duration',
          style: TextStyle(
            color: Color(MyColor.black),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SvgPicture.asset(
              'assets/icons/logo.svg',
              height: 32,
              width: 32,
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Trip image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildImageWidget(),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/logo_avt.svg',
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _duration,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(MyColor.black),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Trip details
                    Container(
                      decoration: BoxDecoration(
                        color: Color(MyColor.pr1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text('Hoạt động: $_activities')),
                              Expanded(child: Text('Nơi ở: $_accommodation')),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(child: Text('Bữa ăn: $_meals')),
                              Expanded(child: Text('Chi phí: ${_price}đ')),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(child: Text('Số người: $_people')),
                              const Expanded(child: Text('')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Rating selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Chất lượng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _ratingText(selectedRating),
                          style: TextStyle(
                            color: Color(MyColor.pr5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              selectedRating = index + 1;
                            });
                          },
                          icon: Icon(
                            Icons.star,
                            size: 32,
                            color:
                                index < selectedRating
                                    ? Colors.amber
                                    : Color(MyColor.grey),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // Comment input
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(MyColor.grey)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: commentController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Hãy chia sẻ nhận xét của bạn',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(MyColor.white),
                          foregroundColor: Color(MyColor.pr5),
                          side: BorderSide(color: Color(MyColor.pr5)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isSaving
                                ? CircularProgressIndicator(
                                  color: Color(MyColor.pr5),
                                )
                                : const Text('Gửi đánh giá'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  // Build image widget
  Widget _buildImageWidget() {
    if (_imageUrl.startsWith('http')) {
      return Image.network(
        _imageUrl,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return Image.asset(
            'assets/images/vungtau.png',
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      return Image.asset(
        'assets/images/vungtau.png',
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
      );
    }
  }
}
