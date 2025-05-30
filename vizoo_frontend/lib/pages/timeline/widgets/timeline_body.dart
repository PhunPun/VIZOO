import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/pages/home/home_page.dart';
import 'package:vizoo_frontend/pages/timeline/timeline_page.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/widgets/set_day_start.dart';
import 'package:vizoo_frontend/widgets/set_people_num.dart';
import 'package:vizoo_frontend/pages/timeline/widgets/timeline_list.dart';
import 'package:vizoo_frontend/widgets/trip_card.dart';

import '../../../models/trip_models_json.dart';
import '../../profile/pages/edit_reviews_screen.dart';
import '../../profile/pages/reviews_screen.dart';

class TimelineBody extends StatefulWidget {
  final String tripId;
  final String locationId;
  final VoidCallback? onDataChanged;
  final String? se_tripId;

  const TimelineBody({
    super.key,
    required this.tripId,
    required this.locationId,
    this.onDataChanged,
    this.se_tripId,
  });

  @override
  State<TimelineBody> createState() => _TimelineBodyState();
}

class _TimelineBodyState extends State<TimelineBody> {
  Trip? tripData;
  DateTime initDate = DateTime.now();
  List<int> days = [];
  String? se_tripId;
  late final DocumentReference<Map<String, dynamic>> _masterTripRef;
  DocumentReference<Map<String, dynamic>>? _userTripRef;
  bool _useUserData = false;
  // Lưu trạng thái chuyến đi của người dùng hiện tại (0: đang áp dụng, 1: hoàn thành, 2: đã hủy)
  int? userTripStatus;
  String? userTripDocId;
  int? check;

  // Kiểm tra tất cả các mốc thời gian đã hoàn thành chưa
  bool allActivitiesCompleted = false;
  bool isCheckingActivities = false;
  bool isLoading = false;

  // Lưu thông tin đánh giá
  bool hasReview = false;
  String reviewId = '';

  late Future<void> _initDataFuture;
  @override
  void initState() {
    super.initState();
    _initDataFuture = _initializeData();
    _masterTripRef = FirebaseFirestore.instance
        .collection('dia_diem')
        .doc(widget.locationId)
        .collection('trips')
        .doc(widget.tripId);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (widget.se_tripId != null) {
        _userTripRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('selected_trips')
            .doc(widget.se_tripId);
        se_tripId = widget.se_tripId;
      } else {
        final newDocRef =
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('selected_trips')
                .doc();

        _userTripRef = newDocRef;
        se_tripId = newDocRef.id;
      }
    }
    _loadTripData().then((_) {
      _fetchDayNumbers();
      _loadTripDetails();
    });
  }

  Future<void> _loadTripData() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userTripSnapshot = await _userTripRef!.get();

      if (userTripSnapshot.exists) {
        if (!mounted) return;
        
        // Get the most recent accommodation if there are multiple
        String accommodation = userTripSnapshot.data()!['noi_o'] ?? 'Không xác định';
        
        setState(() {
          _useUserData = true;
          tripData = Trip.fromJson(
            userTripSnapshot.data()!,
            id: widget.tripId,
            locationId: widget.locationId,
          );
          
          // Make sure to update the accommodation with the most recent one
          tripData = tripData!.copyWith(noiO: accommodation);
          
          initDate = tripData!.ngayBatDau;
          check = tripData!.check;
        });
        return;
      }
    }

    // Chỉ load từ master nếu không có dữ liệu user
    final snapMaster = await _masterTripRef.get();
    if (snapMaster.exists) {
      if (!mounted) return;
      setState(() {
        _useUserData = false;
        tripData = Trip.fromJson(
          snapMaster.data()!,
          id: widget.tripId,
          locationId: widget.locationId,
        );
        initDate = tripData!.ngayBatDau;
        check = tripData!.check;
      });
    }
  } catch (e) {
    print('Lỗi khi lấy dữ liệu chuyến đi: $e');
  }
}

  @override
  void dispose() {
    // Dọn dẹp tài nguyên nếu cần
    print('TimelineBody dispose - tripId: ${widget.tripId}');
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      print('didChangeDependencies called - Reloading data');
      _initDataFuture = _initializeData();
      _fetchDayNumbers();
      _loadTripDetails();
      _loadUserTripStatus();
      _loadActivityHotel();
    }
  }

  @override
  void didUpdateWidget(TimelineBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Kiểm tra nếu thông tin trip thay đổi, reload dữ liệu
    if (oldWidget.tripId != widget.tripId ||
        oldWidget.locationId != widget.locationId) {
      print('Trip ID hoặc Location ID thay đổi, tải lại dữ liệu');
      _initDataFuture = _initializeData();
    }
  }

  Future<void> updateTripStatus(int newStatus) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần đăng nhập để thực hiện chức năng này'),
        ),
      );
      return;
    }

    // Kiểm tra các điều kiện logic
    // Không cho phép quay lại trạng thái "áp dụng" nếu đã hoàn thành
    if (widget.se_tripId == null) {
      if (userTripStatus == 1 && newStatus == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Không thể quay lại trạng thái đang áp dụng sau khi đã hoàn thành.'
              ' Vui lòng sử dụng "Áp dụng lại" để bắt đầu mới.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Kiểm tra các điều kiện trước khi cập nhật trạng thái
      if (newStatus == 1 && !allActivitiesCompleted) {
        // Nếu muốn hoàn thành chuyến đi nhưng chưa hoàn thành tất cả hoạt động
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Chưa hoàn thành'),
                content: const Text(
                  'Bạn cần hoàn thành tất cả các hoạt động trong lịch trình trước khi đánh dấu chuyến đi là hoàn thành.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Đã hiểu'),
                  ),
                ],
              ),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        final Timestamp now = Timestamp.now();
        final usersCol = FirebaseFirestore.instance.collection('users');

        // Cập nhật dữ liệu chung cho cả 2 trường hợp
        final updateData = {
          'check': newStatus,
          'trip_id': widget.se_tripId,
          'updated_at': now,
          'status': newStatus == 0, // status = true chỉ khi đang áp dụng (0)
        };

        if (userTripDocId != null) {
          // Cập nhật user_trip và selected_trips đồng thời
          await Future.wait([
            FirebaseFirestore.instance
                .collection('user_trip')
                .doc(userTripDocId)
                .update(updateData),

            usersCol
                .doc(currentUserId)
                .collection('selected_trips')
                .doc(widget.se_tripId)
                .set(updateData, SetOptions(merge: true)),
          ]);
        } else {
          // Tạo mới và đồng bộ dữ liệu
          final docRef = await FirebaseFirestore.instance
              .collection('user_trip')
              .add({
                'user_id': currentUserId,
                'se_trip_id': widget.se_tripId,
                ...updateData,
                'created_at': now,
              });

          await usersCol
              .doc(currentUserId)
              .collection('selected_trips')
              .doc(widget.se_tripId)
              .update({'check': newStatus, 'status': newStatus = 0});

          setState(() => userTripDocId = docRef.id);
        }

        setState(() => userTripStatus = newStatus);

        String statusText = '';
        switch (newStatus) {
          case 0:
            statusText = 'đang áp dụng';
            break;
          case 1:
            statusText = 'đã hoàn thành';
            break;
          case 2:
            statusText = 'đã hủy';
            break;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chuyến đi đã được cập nhật thành $statusText'),
          ),
        );

        // Nếu đã hoàn thành (1), yêu cầu đánh giá
        if (newStatus == 1) {
          await _navigateToReview(newStatus);
          // Cập nhật lại trạng thái đánh giá
          await checkIfReviewed();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi cập nhật trạng thái: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      if (userTripStatus == 1 && newStatus == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Không thể quay lại trạng thái đang áp dụng sau khi đã hoàn thành.'
              ' Vui lòng sử dụng "Áp dụng lại" để bắt đầu mới.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Kiểm tra các điều kiện trước khi cập nhật trạng thái
      if (newStatus == 1 && !allActivitiesCompleted) {
        // Nếu muốn hoàn thành chuyến đi nhưng chưa hoàn thành tất cả hoạt động
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Chưa hoàn thành'),
                content: const Text(
                  'Bạn cần hoàn thành tất cả các hoạt động trong lịch trình trước khi đánh dấu chuyến đi là hoàn thành.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Đã hiểu'),
                  ),
                ],
              ),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        final Timestamp now = Timestamp.now();
        final usersCol = FirebaseFirestore.instance.collection('users');

        // Cập nhật dữ liệu chung cho cả 2 trường hợp
        final updateData = {
          'check': newStatus,
          'updated_at': now,
          'status': newStatus == 0, // status = true chỉ khi đang áp dụng (0)
        };

        if (userTripDocId != null) {
          // Cập nhật user_trip và selected_trips đồng thời
          await Future.wait([
            FirebaseFirestore.instance
                .collection('user_trip')
                .doc(userTripDocId)
                .update(updateData),

            usersCol
                .doc(currentUserId)
                .collection('selected_trips')
                .doc(widget.se_tripId)
                .set(updateData, SetOptions(merge: true)),
          ]);
        } else {
          // Tạo mới và đồng bộ dữ liệu
          final docRef = await FirebaseFirestore.instance
              .collection('user_trip')
              .add({
                'user_id': currentUserId,
                'se_trip_id': widget.se_tripId,
                ...updateData,
                'created_at': now,
              });

          await usersCol
              .doc(currentUserId)
              .collection('selected_trips')
              .doc(widget.se_tripId)
              .update({'check': newStatus, 'status': newStatus = 0});

          setState(() => userTripDocId = docRef.id);
        }

        setState(() => userTripStatus = newStatus);

        String statusText = '';
        switch (newStatus) {
          case 0:
            statusText = 'đang áp dụng';
            break;
          case 1:
            statusText = 'đã hoàn thành';
            break;
          case 2:
            statusText = 'đã hủy';
            break;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chuyến đi đã được cập nhật thành $statusText'),
          ),
        );

        // Nếu đã hoàn thành (1), yêu cầu đánh giá
        if (newStatus == 1) {
          await _navigateToReview(newStatus);
          // Cập nhật lại trạng thái đánh giá
          await checkIfReviewed();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi cập nhật trạng thái: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Phương thức nâng cao để chuyển đến trang đánh giá
  void _navigateToReviewScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewListView(se_tripID: se_tripId),
      ),
    );
  }

  Future<void> _initializeData() async {
    try {
      await _loadUserTripStatus();
      await checkIfReviewed();
    } catch (e) {
      print('Lỗi khi khởi tạo dữ liệu: $e');
    }
  }

  Future<void> _loadUserTripStatus() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;
    if (widget.se_tripId != null) {
      try {
        final userTripQuery =
            await FirebaseFirestore.instance
                .collection('user_trip')
                .where('user_id', isEqualTo: currentUserId)
                .where('se_trip_id', isEqualTo: widget.se_tripId)
                .limit(1)
                .get();

        if (userTripQuery.docs.isNotEmpty) {
          final userTripDoc = userTripQuery.docs.first;
          setState(() {
            userTripDocId = userTripDoc.id;
            userTripStatus = userTripDoc.data()['check'] as int? ?? 0;
            _useUserData = true;
          });
          print(
            'Found user trip with status: $userTripStatus, docId: $widget.se_tripId',
          );
          return;
        }

        // If not found in user_trip, check selected_trips
        if (currentUserId != null) {
          final selectedTripRef = FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .collection('selected_trips')
              .doc(widget.se_tripId);

          final selectedTripSnap = await selectedTripRef.get();

          if (selectedTripSnap.exists) {
            final checkValue = selectedTripSnap.data()?['check'] as int?;
            setState(() {
              userTripStatus = checkValue;
              _useUserData = true;
            });
            print('Found selected trip with status: $userTripStatus');
          }
        }
      } catch (e) {
        print('Error loading user trip status: $e');
      }
    }
  }

  Future<void> checkAllActivitiesCompleted() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        allActivitiesCompleted = false;
      });
      return;
    }
    final userId = currentUser.uid;

    if (days.isEmpty) {
      setState(() {
        allActivitiesCompleted = false;
      });
      return;
    }

    setState(() {
      isCheckingActivities = true;
    });

    try {
      bool allCompleted = true;
      int totalActivities = 0;
      int completedCount = 0;

      final timelinesSnap =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('selected_trips')
              .doc(widget.se_tripId)
              .collection('timelines')
              .where('day_number', whereIn: days)
              .get();

      for (var tlDoc in timelinesSnap.docs) {
        final scheduleSnap = await tlDoc.reference.collection('schedule').get();

        totalActivities += scheduleSnap.docs.length;

        for (var schedDoc in scheduleSnap.docs) {
          final status = schedDoc.data()['status'] as bool? ?? false;
          final isDone = status;

          if (isDone) {
            completedCount++;
          } else {
            allCompleted = false;
          }
        }
      }

      setState(() {
        allActivitiesCompleted = (totalActivities > 0) && allCompleted;
        isCheckingActivities = false;
      });

      print(
        'Hoàn thành: $completedCount / $totalActivities hoạt động của user $userId',
      );
    } catch (e) {
      print('Lỗi khi kiểm tra hoạt động đã hoàn thành: $e');
      setState(() {
        allActivitiesCompleted = false;
        isCheckingActivities = false;
      });
    }
  }

  // Phương thức đưa người dùng đến trang đánh giá khi hoàn thành chuyến đi
  Future<void> _navigateToReview(int tripStatus) async {
    if (tripData == null) return;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) return;

    try {
      // Kiểm tra xem người dùng đã có đánh giá cho chuyến đi này chưa
      final existingReviewSnapshot =
          await FirebaseFirestore.instance
              .collection('reviews')
              .where('user_id', isEqualTo: currentUserId)
              .where('se_trip_id', isEqualTo: widget.se_tripId)
              .get();

      if (existingReviewSnapshot.docs.isNotEmpty) {
        // Đã có đánh giá, không cần tạo mới
        setState(() {
          hasReview = true;
          reviewId = existingReviewSnapshot.docs.first.id;
        });
        return;
      }

      // Tìm thông tin chuyến đi từ selected_trips
      Map<String, dynamic> tripInfo = {};
      String actualSeTripId = widget.se_tripId ?? '';

      // Lấy thông tin chính xác từ user_trip nếu có
      String masterTripId = widget.tripId; // Giá trị mặc định

      // Tìm user_trip document để lấy trip_id chính xác
      if (actualSeTripId.isNotEmpty) {
        try {
          final userTripSnapshot =
              await FirebaseFirestore.instance
                  .collection('user_trip')
                  .where('user_id', isEqualTo: currentUserId)
                  .where('se_trip_id', isEqualTo: actualSeTripId)
                  .limit(1)
                  .get();

          if (userTripSnapshot.docs.isNotEmpty) {
            // Lấy trip_id từ user_trip collection
            final userTripData = userTripSnapshot.docs.first.data();
            masterTripId = userTripData['trip_id'] ?? widget.tripId;

            print('Lấy được trip_id từ user_trip: $masterTripId');
          } else {
            print(
              'Không tìm thấy document trong user_trip với se_trip_id: $actualSeTripId',
            );
          }
        } catch (e) {
          print('Lỗi khi truy vấn user_trip: $e');
        }
      }

      if (actualSeTripId.isNotEmpty) {
        final seTripDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserId)
                .collection('selected_trips')
                .doc(actualSeTripId)
                .get();

        if (seTripDoc.exists) {
          final seTripData = seTripDoc.data() ?? {};

          // Lấy thông tin địa điểm
          String locationName = 'Không xác định';
          String imageUrl = 'assets/images/vungtau.png';

          if (widget.locationId.isNotEmpty) {
            try {
              final locationDoc =
                  await FirebaseFirestore.instance
                      .collection('dia_diem')
                      .doc(widget.locationId)
                      .get();

              if (locationDoc.exists) {
                final locationData = locationDoc.data() ?? {};
                locationName =
                    locationData['ten']?.toString() ?? 'Không xác định';

                if (locationData.containsKey('hinh_anh1') &&
                    locationData['hinh_anh1'] != null &&
                    locationData['hinh_anh1'].toString().isNotEmpty) {
                  imageUrl = locationData['hinh_anh1'].toString();
                }
              }
            } catch (e) {
              print('Lỗi khi lấy thông tin địa điểm: $e');
            }
          }

          // Định dạng thông tin ngày
          final soDays = _extractIntValue(seTripData, 'so_ngay', 1);

          // Tạo đối tượng review - Sử dụng masterTripId đã lấy được từ user_trip
          tripInfo = {
            'trip_id': masterTripId, // Sử dụng trip_id lấy từ user_trip
            'location_id': widget.locationId,
            'se_trip_id': actualSeTripId, // User's selected trip ID
            'location': locationName,
            'duration': '$soDays ngày ${soDays > 1 ? (soDays - 1) : 0} đêm',
            'imageUrl': seTripData['anh'] ?? imageUrl,
            'accommodation': seTripData['noi_o'] ?? 'Không xác định',
            'price': _extractIntValue(seTripData, 'chi_phi', 0),
            'people': _extractIntValue(seTripData, 'so_nguoi', 1),
            'activities': _extractIntValue(seTripData, 'so_act', 0),
            'meals': _extractIntValue(seTripData, 'so_eat', 0),
            'completion_date': _formatDate(DateTime.now()),
            'userTripDocId': userTripDocId,
          };
        }
      }

      // Nếu không có dữ liệu, tạo dữ liệu đơn giản từ tripData
      if (tripInfo.isEmpty && tripData != null) {
        String locationName = tripData!.tripName;
        String imageUrl = tripData!.anh ?? 'assets/images/vungtau.png';

        // Thử lấy thông tin từ dia_diem
        if (widget.locationId.isNotEmpty) {
          try {
            final locationDoc =
                await FirebaseFirestore.instance
                    .collection('dia_diem')
                    .doc(widget.locationId)
                    .get();

            if (locationDoc.exists) {
              final locationData = locationDoc.data() ?? {};
              locationName = locationData['ten']?.toString() ?? locationName;

              if (locationData.containsKey('hinh_anh1') &&
                  locationData['hinh_anh1'] != null &&
                  locationData['hinh_anh1'].toString().isNotEmpty) {
                imageUrl = locationData['hinh_anh1'].toString();
              }
            }
          } catch (e) {
            print('Lỗi khi lấy thông tin địa điểm: $e');
          }
        }

        // Sử dụng masterTripId đã lấy được
        tripInfo = {
          'trip_id': masterTripId, // Sử dụng trip_id lấy từ user_trip
          'location_id': widget.locationId,
          'se_trip_id': actualSeTripId, // User's selected trip ID
          'location': locationName,
          'duration':
              '${tripData!.soNgay} ngày ${tripData!.soNgay > 1 ? (tripData!.soNgay - 1) : 0} đêm',
          'imageUrl': imageUrl,
          'accommodation': tripData!.noiO ?? 'Không xác định',
          'price': tripData!.chiPhi,
          'people': tripData!.soNguoi,
          'activities': tripData!.soAct ?? 0,
          'meals': tripData!.soEat ?? 0,
          'completion_date': _formatDate(DateTime.now()),
          'userTripDocId': userTripDocId,
        };
      }

      // Log để debug
      print('Dữ liệu review trước khi gửi đến EditReviewScreen:');
      print('master trip_id: $masterTripId');
      print('se_trip_id (user): $actualSeTripId');
      print('Full tripInfo: $tripInfo');

      // Nếu chuyến đi đã hoàn thành, hỏi người dùng có muốn đánh giá ngay không
      if (tripStatus == 1) {
        final shouldReview =
            await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Đánh giá chuyến đi'),
                    content: const Text(
                      'Bạn đã hoàn thành chuyến đi! Bạn có muốn đánh giá ngay không?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          'Để sau',
                          style: TextStyle(color: Color(MyColor.pr3)),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          'Đánh giá ngay',
                          style: TextStyle(color: Color(MyColor.pr5)),
                        ),
                      ),
                    ],
                  ),
            ) ??
            false;

        if (shouldReview) {
          print('Dữ liệu review: $tripInfo'); // Ghi log để kiểm tra

          // Thêm các trường cần thiết
          tripInfo['user_id'] = currentUserId;

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => EditReviewScreen(
                    review: tripInfo,
                    isNewReview: true,
                    userId: currentUserId,
                  ),
            ),
          );

          if (result == true) {
            // Reload lại dữ liệu đánh giá sau khi đã tạo xong
            await checkIfReviewed();

            // Thông báo đã đánh giá thành công
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã đánh giá chuyến đi thành công'),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      print('Lỗi khi chuyển đến trang đánh giá: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  // Phương thức hỗ trợ để định dạng ngày
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Phương thức hỗ trợ để trích xuất giá trị int từ map
  int _extractIntValue(
    Map<String, dynamic> data,
    String key,
    int defaultValue,
  ) {
    if (!data.containsKey(key) || data[key] == null) return defaultValue;

    if (data[key] is int) return data[key];
    return int.tryParse(data[key].toString()) ?? defaultValue;
  }

  Future<void> checkIfReviewed() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      // Nếu có se_trip_id, ưu tiên tìm theo se_trip_id trước
      if (widget.se_tripId != null && widget.se_tripId!.isNotEmpty) {
        final reviewBySeTrip =
            await FirebaseFirestore.instance
                .collection('reviews')
                .where('user_id', isEqualTo: currentUserId)
                .where('se_trip_id', isEqualTo: widget.se_tripId)
                .limit(1)
                .get();

        if (reviewBySeTrip.docs.isNotEmpty) {
          setState(() {
            hasReview = true;
            reviewId = reviewBySeTrip.docs.first.id;
          });
          return;
        }
      }

      // Nếu không tìm thấy theo se_trip_id hoặc không có se_trip_id, tìm theo trip_id
      final reviewSnapshot =
          await FirebaseFirestore.instance
              .collection('reviews')
              .where('user_id', isEqualTo: currentUserId)
              .where('trip_id', isEqualTo: widget.tripId)
              .limit(1)
              .get();

      setState(() {
        hasReview = reviewSnapshot.docs.isNotEmpty;
        if (hasReview && reviewSnapshot.docs.isNotEmpty) {
          reviewId = reviewSnapshot.docs.first.id;
        }
      });
    } catch (e) {
      print('Lỗi khi kiểm tra đánh giá: $e');
    }
  }

  Future<void> _fetchDayNumbers() async {
    try {
      final baseRef =
          (_useUserData && _userTripRef != null)
              ? _userTripRef!
              : _masterTripRef;

      final snap =
          await baseRef.collection('timelines').orderBy('day_number').get();

      final fetchedDays =
          snap.docs.map((d) => (d.data()['day_number'] as int)).toList();

      if (!mounted) return;
      setState(() {
        days = fetchedDays;
      });
      // Sau khi lấy số ngày, kiểm tra trạng thái hoàn thành các hoạt động
      await checkAllActivitiesCompleted();
    } catch (e) {
      print('Lỗi khi lấy dữ liệu ngày: $e');
    }
  }

  // ✅ Tải lại dữ liệu cho TripCard
  Future<void> _loadTripDetails() async {
    await Future.wait([
      _loadActivityCount(),
      _loadMealCount(),
      _loadTotalCost(),
      _loadActivityHotel(),
    ]);
  }
  Future<void> _loadActivityHotel() async {
  if (!mounted) return;

  final user = FirebaseAuth.instance.currentUser;
  String hotelName = "chưa chonjjj";
  String? latestHour;

  if (user != null && widget.se_tripId != null) {
    final timelines = await _baseTripRef.collection('timelines').get();

    for (var tl in timelines.docs) {
      final sch = await tl.reference.collection('schedule').get();

      for (var doc in sch.docs) {
        final actId = doc.data()['act_id'] as String?;
        final hour = doc.data()['hour'] as String?;

        if (actId == null || hour == null) continue;

        final actDoc = await FirebaseFirestore.instance
            .collection('dia_diem')
            .doc(widget.locationId)
            .collection('activities')
            .doc(actId)
            .get();

        final actData = actDoc.data();
        if (actData != null && actData['categories'] == 'hotel') {
          if (latestHour == null || hour.compareTo(latestHour) > 0) {
            hotelName = actData['name'] ?? "Chưa chọnpppp";
              latestHour = hour;
          }
        }
      }
    }

    // Cập nhật vào Firestore nếu tìm được khách sạn
    if (latestHour != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('selected_trips')
          .doc(widget.se_tripId)
          .update({'noi_o': hotelName});
    } else {
      // Nếu không tìm thấy act hotel, lấy từ Firestore nếu có sẵn
      final doc = await _userTripRef!.get();
      final data = doc.data();
      if (data != null && data['noi_o'] != null) {
        hotelName = data['noi_o'];
      }
    }
  } else {
    final doc = await _masterTripRef.get();
    final data = doc.data();
    if (data != null && data['noi_o'] != null) {
      hotelName = data['noi_o'];
    }
  }

  setState(() => tripData = tripData?.copyWith(noiO: hotelName));
}



  Future<void> _loadActivityCount() async {
    int count = 0;
    final timelines = await _baseTripRef.collection('timelines').get();
    for (var tl in timelines.docs) {
      final sch = await tl.reference.collection('schedule').get();
      count += sch.docs.length;
    }
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (widget.se_tripId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('selected_trips')
            .doc(widget.se_tripId)
            .update({'so_act': count});
      }
    }
    setState(() => tripData = tripData?.copyWith(soAct: count));
  }

  Future<void> _loadMealCount() async {
    int count = 0;
    final timelines = await _baseTripRef.collection('timelines').get();
    for (var tl in timelines.docs) {
      final sch = await tl.reference.collection('schedule').get();
      for (var doc in sch.docs) {
        final actId = doc.data()['act_id'] as String?;
        if (actId == null) continue;
        final actDoc =
            await FirebaseFirestore.instance
                .collection('dia_diem')
                .doc(widget.locationId)
                .collection('activities')
                .doc(actId)
                .get();
        if (actDoc.exists && actDoc.data()?['categories'] == 'eat') {
          count++;
        }
      }
    }
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (widget.se_tripId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('selected_trips')
            .doc(widget.se_tripId)
            .update({'so_eat': count});
      }
    }
    setState(() => tripData = tripData?.copyWith(soEat: count));
  }

  // Method to reset trip progress
  Future<void> _resetTripProgress() async {
    // Hiển thị hộp thoại xác nhận
    bool confirm =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Áp dụng lại'),
                content: const Text(
                  'Bạn có chắc chắn muốn áp dụng lại chuyến đi này? Tất cả tiến độ sẽ được làm mới.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(color: Color(MyColor.pr3)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(color: Color(MyColor.pr5)),
                    ),
                  ),
                ],
              ),
        ) ??
        false;

    if (!confirm) return;

    setState(() => isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Reset trạng thái các hoạt động trong bản copy của user
      final timelines = await _baseTripRef.collection('timelines').get();

      await Future.wait(
        timelines.docs.map((timeline) async {
          final schedules =
              await timeline.reference.collection('schedule').get();
          await Future.wait(
            schedules.docs.map(
              (schedule) => schedule.reference.update({'status': false}),
            ),
          );
        }),
      );

      // Cập nhật trạng thái trong cả 2 collection
      final now = Timestamp.now();
      if (currentUser == null) return;

      // Đọc dữ liệu gốc từ se_tripId
      final originalRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('selected_trips')
          .doc(widget.se_tripId);

      final originalSnap = await originalRef.get();

      if (!originalSnap.exists) {
        print('❌ se_tripId không tồn tại');
        return;
      }

      if (currentUser == null) return;
      final userId = currentUser.uid;

      // 1. Đọc document gốc từ selected_trips/{se_tripId}
      final originalTripRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('selected_trips')
          .doc(widget.se_tripId);

      if (!originalSnap.exists) {
        print('❌ Không tìm thấy trip gốc với ID: ${widget.se_tripId}');
        return;
      }

      // 2. Tạo document mới (ID tự sinh)
      final newTripRef =
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('selected_trips')
              .doc(); // mới
      se_tripId = newTripRef.id;
      // 3. Sao chép dữ liệu gốc
      await newTripRef.set({
        ...originalSnap.data()!,
        'check': 0,
        'status': true,
        'copied_from': widget.se_tripId,
        'saved_at': now,
      });

      // 4. Sao chép các `timelines` và `schedule`
      final timelinesSnap = await originalTripRef.collection('timelines').get();

      for (final timelineDoc in timelinesSnap.docs) {
        final newTimelineRef = newTripRef
            .collection('timelines')
            .doc(timelineDoc.id);

        // copy timeline
        await newTimelineRef.set({
          ...timelineDoc.data(),
          'location_id': widget.locationId, // nếu cần
        });

        // copy schedule bên trong timeline đó
        final scheduleSnap =
            await timelineDoc.reference.collection('schedule').get();
        for (final scheduleDoc in scheduleSnap.docs) {
          await newTimelineRef.collection('schedule').doc(scheduleDoc.id).set({
            ...scheduleDoc.data(),
            'location_id': widget.locationId, // nếu cần
          });
        }
      }

      print('✅ Đã sao chép selected_trip và toàn bộ timeline + schedule!');

      //  Cập nhật state và reload dữ liệu
      await Future.wait([
        _loadTripData(),
        _fetchDayNumbers(),
        _loadTripDetails(),
      ]);

      setState(() {
        userTripStatus = 0;
        allActivitiesCompleted = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage(se_tripId: se_tripId)),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thiết lập lại chuyến đi thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi thiết lập lại: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Hàm tạo mới user_trip khi người dùng áp dụng lần đầu
  Future<void> createNewUserTrip() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập để áp dụng chuyến đi')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final Timestamp now = Timestamp.now();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Có thể hiển thị thông báo hoặc điều hướng đến trang đăng nhập
        print('Người dùng chưa đăng nhập.');
        return;
      }
      // Kiểm tra xem đã có trip nào đang active chưa
      final activeTrips =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('selected_trips')
              .where('status', isEqualTo: true)
              .get();
      if (activeTrips.docs.isNotEmpty) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Đang có chuyến đi hoạt động'),
                content: const Text(
                  'Bạn đang có một chuyến đi chưa hoàn thành. '
                  'Vui lòng hoàn thành hoặc hủy chuyến đi hiện tại trước khi áp dụng mới.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đã hiểu'),
                  ),
                ],
              ),
        );
        return;
      }

      //Cập nhật user document trong selected_trips
      // Lấy dữ liệu gốc từ master trip
      if (widget.se_tripId == null || widget.se_tripId == "") {
        final masterTripSnapshot = await _masterTripRef.get();
        if (!masterTripSnapshot.exists) return;

        // Tạo document chính với locationID
        await _userTripRef!.set({
          ...masterTripSnapshot.data()!,
          'location_id': widget.locationId, // Thêm locationID
          'status': true,
          'trip_id': widget.tripId,
          'check': 0,
          'saved_at': FieldValue.serverTimestamp(),
        });

        // Copy timelines và schedule
        final timelinesSnapshot =
            await _masterTripRef.collection('timelines').get();

        for (var timelineDoc in timelinesSnapshot.docs) {
          final timelinePath = _userTripRef!
              .collection('timelines')
              .doc(timelineDoc.id);

          await timelinePath.set({
            ...timelineDoc.data(),
            'location_id':
                widget.locationId, // Thêm locationID cho từng timeline
          });

          final scheduleSnapshot =
              await timelineDoc.reference.collection('schedule').get();
          for (var scheduleDoc in scheduleSnapshot.docs) {
            await timelinePath.collection('schedule').doc(scheduleDoc.id).set({
              ...scheduleDoc.data(),
              'location_id':
                  widget.locationId, // Thêm locationID cho từng schedule
            });
          }
        }
      } else {
        final userTripSnapshot = await _userTripRef!.get();
        if (!userTripSnapshot.exists) return;

        // Tạo document chính với locationID
        await _userTripRef!.set({
          ...userTripSnapshot.data()!,
          'location_id': widget.locationId,
          'trip_id': widget.tripId, // Thêm locationID
          'status': true,
          'check': 0,
          'saved_at': FieldValue.serverTimestamp(),
        });
      }

      // Tạo mới bản ghi user_trip với trạng thái mặc định là đang áp dụng (0)
      final docRef = await FirebaseFirestore.instance
          .collection('user_trip')
          .add({
            'user_id': currentUserId,
            'se_trip_id': se_tripId,
            'trip_id': widget.tripId,
            'check': 0,
            'created_at': now,
            'updated_at': now,
          });

      // Ensure consistent status values in both collections
      await Future.wait([
        // Update user_trip with consistent status values
        FirebaseFirestore.instance
            .collection('user_trip')
            .doc(docRef.id)
            .update({'check': 0, 'status': true, 'updated_at': now}),

        // Make sure selected_trips has the same status values
        _userTripRef!.update({'check': 0, 'status': true, 'last_updated': now}),
      ]);

      setState(() {
        userTripStatus = 0;
        userTripDocId = docRef.id;
        _useUserData = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã áp dụng chuyến đi thành công')),
      );
      if (widget.se_tripId == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomePage(se_tripId: se_tripId)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi áp dụng chuyến đi: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadTotalCost() async {
    double sum = 0;
    final timelines = await _baseTripRef.collection('timelines').get();
    for (var tl in timelines.docs) {
      final sch = await tl.reference.collection('schedule').get();
      int soNguoi = 1;
      for (var doc in sch.docs) {
        final actId = doc.data()['act_id'] as String?;
        if (actId == null) continue;
        final actDoc =
            await FirebaseFirestore.instance
                .collection('dia_diem')
                .doc(widget.locationId)
                .collection('activities')
                .doc(actId)
                .get();
        if (actDoc.exists) {
          sum += (actDoc.data()?['price'] ?? 0).toDouble();

          if (widget.se_tripId != null) {
            final user = FirebaseAuth.instance.currentUser;
            final seTripCost =
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .collection('selected_trips')
                    .doc(
                      widget.se_tripId!,
                    ) // an toàn vì đã kiểm tra null phía trên
                    .get();

            soNguoi = seTripCost.data()?['so_nguoi'] ?? 1;
          } else {
            final tripCost =
                await FirebaseFirestore.instance
                    .collection('dia_diem')
                    .doc(widget.locationId)
                    .collection('trips')
                    .doc(widget.tripId)
                    .get();

            soNguoi = tripCost.data()?['so_nguoi'] ?? 1;
          }
        }
      }
      sum *= soNguoi;
    }
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (widget.se_tripId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('selected_trips')
            .doc(widget.se_tripId)
            .update({'chi_phi': sum.toInt()});
      }
    }
    setState(() => tripData = tripData?.copyWith(chiPhi: sum.toInt()));
  }

  void onSetPeople(int newCount) {
    if (tripData != null) {
      setState(() {
        tripData = tripData!.copyWith(soNguoi: newCount);
      });
    }
  }

  void onChangeDate(DateTime newDate) {
    setState(() {
      initDate = newDate;
    });
  }

  DocumentReference<Map<String, dynamic>> get _baseTripRef =>
      (_useUserData && _userTripRef != null) ? _userTripRef! : _masterTripRef;

  @override
  Widget build(BuildContext context) {
    if (tripData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TripCard(trip: tripData!),
          SetPeopleNum(
            peopleNum: tripData!.soNguoi,
            cost: tripData!.chiPhi,
            onSetPeople: onSetPeople,
            onSetCost: (_) => _loadTripDetails(),
            diaDiemId: widget.locationId,
            tripId: widget.tripId,
            se_tripId: widget.se_tripId,
          ),
          SetDayStart(
            dateStart: initDate,
            numberDay: tripData!.soNgay,
            onChangeDate: onChangeDate,
            locationId: widget.locationId,
            tripId: widget.tripId,
            se_tripId: widget.se_tripId,
          ),
          const SizedBox(height: 16),
          if (days.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Không có lịch trình cho ngày nào'),
            )
          else
            ...days.map((day) {
              final query = _baseTripRef
                  .collection('timelines')
                  .where('day_number', isEqualTo: day);

              return TimelineList(
                numberDay: day,
                timelineQuery: query,
                locationId: widget.locationId,
                tripId: widget.tripId,
                onDataChanged: () async {
                  await _loadTripData();
                  await _fetchDayNumbers();
                  await _loadTripDetails();
                  widget.onDataChanged?.call();
                },
                onActivityStatusChanged: () {
                  checkAllActivitiesCompleted();
                },
                se_tripId: widget.se_tripId,
              );
            }).toList(),
          SizedBox(height: 12),
          //           Container(
          //             padding: const EdgeInsets.only(bottom: 30),
          //             child: Center(
          //               child: tripData == null
          //                   ? const CircularProgressIndicator()
          //                   : ElevatedButton(
          //                 onPressed: () async {
          //                   try {
          //                     final user = FirebaseAuth.instance.currentUser;
          //                     if (user == null) return;
          //
          //                     // Kiểm tra chỉ apply khi đang chưa apply hoặc đã dừng trước đó
          //                     final selectedTrips = await FirebaseFirestore.instance
          //                         .collection('users')
          //                         .doc(user.uid)
          //                         .collection('selected_trips')
          //                         .where('status', isEqualTo: true)
          //                         .get();
          //
          //                     if (!tripData!.status! && selectedTrips.docs.isNotEmpty) {
          //                       ScaffoldMessenger.of(context).showSnackBar(
          //                         const SnackBar(
          //                           content: Text(
          //                             'Bạn đã có một hành trình đang áp dụng. '
          //                                 'Vui lòng dừng hoặc hoàn thành hành trình đó trước.',
          //                           ),
          //                         ),
          //                       );
          //                       return;
          //                     }
          //
          //                     // Copy master → user lần đầu nếu cần
          //                     if (!_useUserData && _userTripRef != null) {
          //                       final masterSnap = await _masterTripRef.get();
          //                       if (masterSnap.exists) {
          //                         await _userTripRef!.set({
          //                           ...masterSnap.data()!,
          //                           'saved_at': FieldValue.serverTimestamp(),
          //                           'location_id': widget.locationId,
          //                         }, SetOptions(merge: true));
          //
          //                         final tlSnap = await _masterTripRef.collection('timelines').get();
          //                         for (var tl in tlSnap.docs) {
          //                           await _userTripRef!
          //                               .collection('timelines')
          //                               .doc(tl.id)
          //                               .set(tl.data(), SetOptions(merge: true));
          //                           final schSnap = await tl.reference.collection('schedule').get();
          //                           for (var sch in schSnap.docs) {
          //                             await _userTripRef!
          //                                 .collection('timelines')
          //                                 .doc(tl.id)
          //                                 .collection('schedule')
          //                                 .doc(sch.id)
          //                                 .set(sch.data(), SetOptions(merge: true));
          //                           }
          //                         }
          //                         _useUserData = true;
          //                       }
          //                     }
          //
          //                     final targetRef = (_useUserData && _userTripRef != null)
          //                         ? _userTripRef!
          //                         : _masterTripRef;
          //
          //                     // Xác định trạng thái mới
          //                     final isApplying = !tripData!.status!; // true = apply, false = dừng
          //                     final newStatus  = isApplying;
          //
          //                     // Cập nhật đồng thời status và check
          //                     await targetRef.update({
          //                       'status': newStatus,
          //                       if (isApplying)
          //                         'check': 0
          //                       else
          //                         'check': FieldValue.delete(),
          //                       'updated_at': FieldValue.serverTimestamp(),
          //                     });
          //
          //                     // Cập nhật model để rebuild
          //                     setState(() {
          //                       tripData = tripData!.copyWith(
          //                         status: newStatus,
          //                         check: isApplying ? 0 : null,
          //                       );
          //                     });
          //
          //                     ScaffoldMessenger.of(context).showSnackBar(
          //                       SnackBar(
          //                         content: Text(
          //                           isApplying
          //                               ? 'Áp dụng thành công'
          //                               : 'Dừng hành trình thành công',
          //                         ),
          //                       ),
          //                     );
          //                   } catch (e) {
          //                     ScaffoldMessenger.of(context).showSnackBar(
          //                       SnackBar(content: Text('Lỗi khi cập nhật: $e')),
          //                     );
          //                   }
          //                 },
          //                 style: ElevatedButton.styleFrom(
          //                   backgroundColor: Color(MyColor.pr4),
          //                   padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          //                   shape: RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(12),
          //                   ),
          //                 ),
          //                 child: Text(
          //                   tripData!.status! ? 'Dừng hành trình' : 'Áp dụng',
          //                   style: const TextStyle(
          //                     color: Colors.white,
          //                     fontSize: 16,
          //                     fontWeight: FontWeight.w500,
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     );
          //   }
          // }
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Hiển thị tiêu đề khác nhau dựa trên trạng thái chuyến đi
                if (userTripStatus == null)
                  Center(
                    child: Text(
                      'Bắt đầu hành trình của bạn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(MyColor.pr5),
                      ),
                    ),
                  )
                else
                  Text(
                    userTripStatus == 0
                        ? 'Cập nhật trạng thái chuyến đi'
                        : 'Thao tác chuyến đi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(MyColor.pr5),
                    ),
                  ),
                const SizedBox(height: 12),

                // Hiển thị nút dựa theo trạng thái chuyến đi
                if (userTripStatus == null)
                  // Chưa có bản ghi - hiển thị nút Áp dụng duy nhất
                  ElevatedButton(
                    onPressed: isLoading ? null : createNewUserTrip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(MyColor.pr4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Áp dụng chuyến đi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                  )
                else if (userTripStatus == 0)
                  // Đang áp dụng - hiển thị 3 nút trạng thái
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed:
                            (isLoading) ? null : () => updateTripStatus(0),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(MyColor.pr3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Đang áp dụng'),
                      ),
                      ElevatedButton(
                        onPressed:
                            (isLoading || !allActivitiesCompleted)
                                ? null
                                : () => updateTripStatus(1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(MyColor.white),
                          foregroundColor: Color(MyColor.pr5),
                          side: BorderSide(color: Color(MyColor.pr5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: Color(
                            MyColor.white,
                          ).withOpacity(0.5),
                          disabledForegroundColor: Color(
                            MyColor.pr5,
                          ).withOpacity(0.5),
                        ),
                        child: const Text('Hoàn thành'),
                      ),
                      ElevatedButton(
                        onPressed:
                            (isLoading) ? null : () => updateTripStatus(2),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(MyColor.white),
                          foregroundColor: Colors.red.shade400,
                          side: BorderSide(color: Colors.red.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ],
                  )
                else
                  // Đã hoàn thành hoặc đã hủy - hiển thị nút đánh giá và áp dụng lại
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nút xem đánh giá cho cả trạng thái đã hoàn thành (1) và đã hủy (2)
                      ElevatedButton.icon(
                        onPressed: _navigateToReviewScreen,
                        icon: Icon(Icons.star, color: Colors.amber),
                        label: Text(
                          hasReview ? 'Xem đánh giá' : 'Đánh giá chuyến đi',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(MyColor.white),
                          foregroundColor: Color(MyColor.pr5),
                          side: BorderSide(color: Color(MyColor.pr5)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Nút áp dụng lại cho cả hai trạng thái
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : _resetTripProgress,
                        icon: Icon(Icons.refresh, color: Color(MyColor.pr5)),
                        label: const Text('Áp dụng lại'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(MyColor.white),
                          foregroundColor: Color(MyColor.pr5),
                          side: BorderSide(color: Color(MyColor.pr5)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                // Nút bắt đầu/dừng hành trình chỉ hiển thị khi đang áp dụng
                // if (tripData?.status != null && userTripStatus == 0)
                //   ElevatedButton(
                //     onPressed:
                //         isLoading
                //             ? null
                //             : () async {
                //               try {
                //                 final user = FirebaseAuth.instance.currentUser;
                //                 if (user == null) {
                //                   ScaffoldMessenger.of(context).showSnackBar(
                //                     const SnackBar(
                //                       content: Text(
                //                         'Vui lòng đăng nhập để thực hiện thao tác',
                //                       ),
                //                     ),
                //                   );
                //                   return;
                //                 }

                //                 final newStatus = !tripData!.status;

                //                 // Cập nhật đồng thời cả 2 collection
                //                 await FirebaseFirestore.instance.runTransaction((
                //                   transaction,
                //                 ) async {
                //                   // 1. Cập nhật selected_trips
                //                   final selectedTripRef = FirebaseFirestore
                //                       .instance
                //                       .collection('users')
                //                       .doc(user.uid)
                //                       .collection('selected_trips')
                //                       .doc(widget.se_tripId);

                //                   final selectedTripDoc = await transaction.get(
                //                     selectedTripRef,
                //                   );
                //                   if (!selectedTripDoc.exists)
                //                     throw Exception(
                //                       'Không tìm thấy selected_trip document',
                //                     );

                //                   transaction.update(selectedTripRef, {
                //                     //'status': newStatus,
                //                     'check': newStatus ? 0 : null,
                //                     'updated_at': FieldValue.serverTimestamp(),
                //                   });

                //                   // // 2. Cập nhật user_trip
                //                   // final userTripRef = FirebaseFirestore
                //                   //     .instance
                //                   //     .collection('user_trip')
                //                   //     .doc(userTripDocId);

                //                   // final userTripDoc = await transaction.get(
                //                   //   userTripRef,
                //                   // );
                //                   // if (!userTripDoc.exists)
                //                   //   throw Exception(
                //                   //     'Không tìm thấy user_trip document',
                //                   //   );
                //                   //
                //                   // transaction.update(userTripRef, {
                //                   //   'status': newStatus,
                //                   //   'updated_at':
                //                   //       FieldValue.serverTimestamp(),
                //                   // });
                //                 });

                //                 // Cập nhật state và reload dữ liệu
                //                 setState(() {
                //                   tripData = tripData!.copyWith(
                //                     status: newStatus,
                //                   );
                //                 });
                //                 await _loadTripData();

                //                 ScaffoldMessenger.of(context).showSnackBar(
                //                   SnackBar(
                //                     content: Text(
                //                       newStatus
                //                           ? 'Đã bắt đầu hành trình'
                //                           : 'Đã tạm dừng hành trình',
                //                     ),
                //                   ),
                //                 );
                //               } catch (e) {
                //                 ScaffoldMessenger.of(context).showSnackBar(
                //                   SnackBar(
                //                     content: Text(
                //                       'Lỗi khi cập nhật: ${e.toString()}',
                //                     ),
                //                   ),
                //                 );
                //               }
                //             },
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Color(MyColor.pr4),
                //       foregroundColor: Colors.white,
                //       padding: const EdgeInsets.symmetric(
                //         horizontal: 32,
                //         vertical: 14,
                //       ),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //     ),
                //     child: Text(
                //       check == null ? 'Bắt đầu hành trình' : 'Dừng hành trình',
                //       style: const TextStyle(
                //         color: Colors.white,
                //         fontSize: 16,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //   ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
