import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

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

  // Trip details from various sources
  Map<String, dynamic> _masterTripData = {};
  Map<String, dynamic> _selectedTripData = {};
  Map<String, dynamic> _locationData = {};
  String _imageUrl = 'assets/images/vungtau.png';

  // Activity and meal counts
  int _activities = 0;
  int _meals = 0;

  @override
  void initState() {
    super.initState();
    selectedRating = widget.review['rating'] ?? 0;
    commentController = TextEditingController(
      text: widget.review['comment'] ?? '',
    );
    _loadTripDetails();
  }

  Future<void> _loadTripDetails() async {
    setState(() => _isLoading = true);

    try {
      final tripId = widget.review['trip_id'];
      String locationId = widget.review['location_id'] ?? '';
      String seTripId = widget.review['se_trip_id'] ?? '';

      // Step 1: Try to determine locationId if not provided
      if (locationId.isEmpty && tripId != null) {
        // Extract from tripId if it follows the pattern locationId_xxx
        if (tripId.contains('_')) {
          final parts = tripId.split('_');
          if (parts.length > 1) {
            locationId = parts[0];
          }
        }
      }

      // Step 2: Load location data if we have locationId
      if (locationId.isNotEmpty) {
        final locationDoc =
            await FirebaseFirestore.instance
                .collection('dia_diem')
                .doc(locationId)
                .get();

        if (locationDoc.exists) {
          _locationData = locationDoc.data() ?? {};
          _imageUrl = _locationData['hinh_anh1'] ?? _imageUrl;

          // Step 3: Load master trip data from location
          if (tripId != null) {
            final tripDoc =
                await FirebaseFirestore.instance
                    .collection('dia_diem')
                    .doc(locationId)
                    .collection('trips')
                    .doc(tripId)
                    .get();

            if (tripDoc.exists) {
              _masterTripData = tripDoc.data() ?? {};
              if (_masterTripData.containsKey('anh') &&
                  _masterTripData['anh'] != null &&
                  _masterTripData['anh'].toString().isNotEmpty) {
                _imageUrl = _masterTripData['anh'];
              }
            }
          }
        }
      }

      // Step 4: If we don't have locationId, search all locations
      if (locationId.isEmpty && tripId != null) {
        final locationDocs =
            await FirebaseFirestore.instance.collection('dia_diem').get();

        for (var locDoc in locationDocs.docs) {
          final tripDoc =
              await FirebaseFirestore.instance
                  .collection('dia_diem')
                  .doc(locDoc.id)
                  .collection('trips')
                  .doc(tripId)
                  .get();

          if (tripDoc.exists) {
            locationId = locDoc.id;
            _locationData = locDoc.data() ?? {};
            _masterTripData = tripDoc.data() ?? {};
            _imageUrl = _locationData['hinh_anh1'] ?? _imageUrl;
            if (_masterTripData.containsKey('anh') &&
                _masterTripData['anh'] != null &&
                _masterTripData['anh'].toString().isNotEmpty) {
              _imageUrl = _masterTripData['anh'];
            }
            break;
          }
        }
      }

      // Step 5: Check for user's selected trip data if not provided
      final userId =
          widget.userId.isEmpty
              ? FirebaseAuth.instance.currentUser?.uid
              : widget.userId;

      if (userId != null && tripId != null) {
        // If seTripId is provided, use it directly
        if (seTripId.isNotEmpty) {
          final seTripDoc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('selected_trips')
                  .doc(seTripId)
                  .get();

          if (seTripDoc.exists) {
            _selectedTripData = seTripDoc.data() ?? {};
            // Update image URL if available
            if (_selectedTripData.containsKey('anh') &&
                _selectedTripData['anh'] != null &&
                _selectedTripData['anh'].toString().isNotEmpty) {
              _imageUrl = _selectedTripData['anh'];
            }
          }
        } else {
          // Try to find seTripId from user_trip collection
          final userTripDocs =
              await FirebaseFirestore.instance
                  .collection('user_trip')
                  .where('user_id', isEqualTo: userId)
                  .where('trip_id', isEqualTo: tripId)
                  .limit(1)
                  .get();

          if (userTripDocs.docs.isNotEmpty) {
            final userTripData = userTripDocs.docs.first.data();
            seTripId = userTripData['se_trip_id'] as String? ?? '';

            if (seTripId.isNotEmpty) {
              final seTripDoc =
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('selected_trips')
                      .doc(seTripId)
                      .get();

              if (seTripDoc.exists) {
                _selectedTripData = seTripDoc.data() ?? {};
                // Update image URL if available
                if (_selectedTripData.containsKey('anh') &&
                    _selectedTripData['anh'] != null &&
                    _selectedTripData['anh'].toString().isNotEmpty) {
                  _imageUrl = _selectedTripData['anh'];
                }
              }
            }
          } else {
            // Try to use tripId directly as selected_trip doc ID
            final directSeTripDoc =
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('selected_trips')
                    .doc(tripId)
                    .get();

            if (directSeTripDoc.exists) {
              _selectedTripData = directSeTripDoc.data() ?? {};
              seTripId = tripId;
              // Update image URL if available
              if (_selectedTripData.containsKey('anh') &&
                  _selectedTripData['anh'] != null &&
                  _selectedTripData['anh'].toString().isNotEmpty) {
                _imageUrl = _selectedTripData['anh'];
              }
            }
          }
        }
      }

      // Step 6: Count activities and meals if needed
      // First try to get counts from selected trip data
      if (_selectedTripData.isNotEmpty) {
        _activities =
            _selectedTripData['so_act'] is int
                ? _selectedTripData['so_act']
                : int.tryParse(
                      _selectedTripData['so_act']?.toString() ?? '0',
                    ) ??
                    0;

        _meals =
            _selectedTripData['so_eat'] is int
                ? _selectedTripData['so_eat']
                : int.tryParse(
                      _selectedTripData['so_eat']?.toString() ?? '0',
                    ) ??
                    0;

        // If counts are 0, try to count from timelines
        if ((_activities == 0 || _meals == 0) &&
            userId != null &&
            seTripId.isNotEmpty &&
            locationId.isNotEmpty) {
          final timelinesSnapshot =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('selected_trips')
                  .doc(seTripId)
                  .collection('timelines')
                  .get();

          int actCount = 0;
          int mealCount = 0;

          for (var timeline in timelinesSnapshot.docs) {
            final scheduleSnapshot =
                await timeline.reference.collection('schedule').get();

            actCount += scheduleSnapshot.docs.length;

            for (var schedule in scheduleSnapshot.docs) {
              final actId = schedule.data()['act_id'] as String?;
              if (actId == null || actId.isEmpty) continue;

              final activityDoc =
                  await FirebaseFirestore.instance
                      .collection('dia_diem')
                      .doc(locationId)
                      .collection('activities')
                      .doc(actId)
                      .get();

              if (activityDoc.exists &&
                  activityDoc.data()?['categories'] == 'eat') {
                mealCount++;
              }
            }
          }

          // Update counters
          if (actCount > 0 && _activities == 0) _activities = actCount;
          if (mealCount > 0 && _meals == 0) _meals = mealCount;

          // Update the selected_trips document if needed
          if ((actCount > 0 || mealCount > 0) &&
              userId != null &&
              seTripId.isNotEmpty) {
            try {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('selected_trips')
                  .doc(seTripId)
                  .update({
                    if (actCount > 0) 'so_act': actCount,
                    if (mealCount > 0) 'so_eat': mealCount,
                  });

              // Update _selectedTripData with new counts
              _selectedTripData['so_act'] =
                  actCount > 0 ? actCount : _selectedTripData['so_act'];
              _selectedTripData['so_eat'] =
                  mealCount > 0 ? mealCount : _selectedTripData['so_eat'];
            } catch (e) {
              print('Lỗi khi cập nhật số lượng hoạt động và bữa ăn: $e');
            }
          }
        }
      }

      // If still 0, try from master trip data
      if (_activities == 0 && _masterTripData.containsKey('so_act')) {
        _activities =
            _masterTripData['so_act'] is int
                ? _masterTripData['so_act']
                : int.tryParse(_masterTripData['so_act']?.toString() ?? '0') ??
                    0;
      }

      if (_meals == 0 && _masterTripData.containsKey('so_eat')) {
        _meals =
            _masterTripData['so_eat'] is int
                ? _masterTripData['so_eat']
                : int.tryParse(_masterTripData['so_eat']?.toString() ?? '0') ??
                    0;
      }

      // Step 7: If we still have 0 activities/meals, use the values from review object
      if (_activities == 0 && widget.review.containsKey('activities')) {
        _activities =
            widget.review['activities'] is int
                ? widget.review['activities']
                : int.tryParse(
                      widget.review['activities']?.toString() ?? '0',
                    ) ??
                    0;
      }

      if (_meals == 0 && widget.review.containsKey('meals')) {
        _meals =
            widget.review['meals'] is int
                ? widget.review['meals']
                : int.tryParse(widget.review['meals']?.toString() ?? '0') ?? 0;
      }

      // Step 8: Use image URL from review if we still don't have one
      if (_imageUrl == 'assets/images/vungtau.png' &&
          widget.review.containsKey('imageUrl') &&
          widget.review['imageUrl'] != null &&
          widget.review['imageUrl'].toString().isNotEmpty) {
        _imageUrl = widget.review['imageUrl'];
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('Lỗi khi tải thông tin chuyến đi: $e');
      setState(() => _isLoading = false);
    }
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
        throw Exception("Người dùng chưa đăng nhập");
      }

      if (widget.isNewReview) {
        // Tạo đánh giá mới
        await FirebaseFirestore.instance.collection('reviews').add({
          'user_id': userId,
          'trip_id': widget.review['trip_id'],
          'comment': commentController.text.trim(),
          'votes': selectedRating,
          'created_at': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm đánh giá thành công')),
        );
      } else {
        // Cập nhật đánh giá hiện có
        await FirebaseFirestore.instance
            .collection('reviews')
            .doc(widget.review['id'])
            .update({
              'comment': commentController.text.trim(),
              'votes': selectedRating,
              'updated_at': Timestamp.now(),
            });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật đánh giá thành công')),
        );
      }

      Navigator.pop(
        context,
        true,
      ); // Trở về màn hình trước với kết quả thành công
    } catch (e) {
      print('Lỗi khi lưu đánh giá: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã xảy ra lỗi: $e')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

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
  Widget build(BuildContext context) {
    // Extract location and duration info
    final location = widget.review['location'] ?? 'Không xác định';
    final duration = widget.review['duration'] ?? '';

    // Get accommodation and people count (prefer selected trip data)
    final String accommodation =
        _selectedTripData['noi_o'] ??
        _masterTripData['noi_o'] ??
        widget.review['accommodation'] ??
        'Không xác định';

    final int price =
        _selectedTripData.containsKey('chi_phi')
            ? (_selectedTripData['chi_phi'] is int
                ? _selectedTripData['chi_phi']
                : int.tryParse(
                      _selectedTripData['chi_phi']?.toString() ?? '0',
                    ) ??
                    0)
            : (_masterTripData.containsKey('chi_phi')
                ? (_masterTripData['chi_phi'] is int
                    ? _masterTripData['chi_phi']
                    : int.tryParse(
                          _masterTripData['chi_phi']?.toString() ?? '0',
                        ) ??
                        0)
                : (widget.review['price'] ?? 0));

    final int people =
        _selectedTripData.containsKey('so_nguoi')
            ? (_selectedTripData['so_nguoi'] is int
                ? _selectedTripData['so_nguoi']
                : int.tryParse(
                      _selectedTripData['so_nguoi']?.toString() ?? '1',
                    ) ??
                    1)
            : (_masterTripData.containsKey('so_nguoi')
                ? (_masterTripData['so_nguoi'] is int
                    ? _masterTripData['so_nguoi']
                    : int.tryParse(
                          _masterTripData['so_nguoi']?.toString() ?? '1',
                        ) ??
                        1)
                : (widget.review['people'] ?? 1));

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
          '$location $duration',
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
                    // Image section with improved loading strategy
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          _imageUrl.startsWith('http')
                              ? Image.network(
                                _imageUrl,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Lỗi tải ảnh: $error');
                                  return Image.asset(
                                    'assets/images/vungtau.png',
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                              : Image.asset(
                                'assets/images/vungtau.png',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
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
                          duration,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(MyColor.black),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Trip details information card
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
                              Expanded(child: Text('Nơi ở: $accommodation')),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(child: Text('Bữa ăn: $_meals')),
                              Expanded(child: Text('Chi phí: ${price}đ')),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(child: Text('Số người: $people')),
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
}
