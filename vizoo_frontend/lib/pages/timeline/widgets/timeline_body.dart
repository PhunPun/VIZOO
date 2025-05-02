import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/widgets/set_day_start.dart';
import 'package:vizoo_frontend/widgets/set_people_num.dart';
import 'package:vizoo_frontend/pages/timeline/widgets/timeline_list.dart';
import 'package:vizoo_frontend/widgets/trip_card.dart';
import 'package:vizoo_frontend/models/trip_models_json.dart';
import 'package:vizoo_frontend/pages/profile/pages/edit_reviews_screen.dart';
import 'package:vizoo_frontend/pages/profile/pages/reviews_screen.dart';
import 'package:vizoo_frontend/pages/profile/pages/completed_trip.dart';
import 'package:vizoo_frontend/pages/profile/pages/cancelled_trip.dart';

class TimelineBody extends StatefulWidget {
  final String tripId;
  final String locationId;

  const TimelineBody({
    super.key,
    required this.tripId,
    required this.locationId,
  });

  @override
  State<TimelineBody> createState() => _TimelineBodyState();
}

class _TimelineBodyState extends State<TimelineBody> {
  Trip? tripData;
  DateTime initDate = DateTime.now();
  List<int> days = [];
  bool isLoading = false;

  // Lưu trạng thái chuyến đi của người dùng hiện tại (0: đang áp dụng, 1: hoàn thành, 2: đã hủy)
  int? userTripStatus;
  String? userTripDocId;

  // Kiểm tra tất cả các mốc thời gian đã hoàn thành chưa
  bool allActivitiesCompleted = false;
  bool isCheckingActivities = false;

  // Lưu thông tin đánh giá
  bool hasReview = false;
  String reviewId = '';

  // Future để sử dụng với FutureBuilder
  late Future<void> _initDataFuture;

  @override
void initState() {
  super.initState();
  print('TimelineBody initState - tripId: ${widget.tripId}');
  _initDataFuture = _initializeData();
  
  // Đảm bảo không gọi setState trong initState
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      
    }
  });
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
      // Đảm bảo refresh dữ liệu khi widget được rebuild
      if (mounted) {
        print('didChangeDependencies gọi - Tải lại dữ liệu');
        _initDataFuture = _initializeData();
      }
    }
    @override
void didUpdateWidget(TimelineBody oldWidget) {
  super.didUpdateWidget(oldWidget);
  
  // Kiểm tra nếu thông tin trip thay đổi, reload dữ liệu
  if (oldWidget.tripId != widget.tripId || oldWidget.locationId != widget.locationId) {
    print('Trip ID hoặc Location ID thay đổi, tải lại dữ liệu');
    _initDataFuture = _initializeData();
  }
}
  // Hàm khởi tạo tất cả dữ liệu cần thiết
  Future<void> _initializeData() async {
    try {
      await fetchTripData();
      await fetchDayNumbers();
      await fetchUserTripStatus();
      await checkIfReviewed();
    } catch (e) {
      print('Lỗi khi khởi tạo dữ liệu: $e');
    }
  }

  // Thêm hàm kiểm tra xem người dùng đã đánh giá chuyến đi này chưa
  Future<void> checkIfReviewed() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
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
      
      print('Có đánh giá: $hasReview, Review ID: $reviewId');
    } catch (e) {
      print('Lỗi khi kiểm tra đánh giá: $e');
    }
  }

  Future<void> fetchTripData() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('dia_diem')
              .doc(widget.locationId)
              .collection('trips')
              .doc(widget.tripId)
              .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        final trip = Trip.fromJson(
          data,
          id: widget.tripId,
          locationId: widget.locationId,
        );
        setState(() {
          tripData = trip;
          initDate = trip.ngayBatDau;
        });
      }
    } catch (e) {
      print('Lỗi khi lấy dữ liệu chuyến đi: $e');
    }
  }

  Future<void> fetchUserTripStatus() async {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserId == null) return;

  try {
    print('Đang lấy trạng thái chuyến đi cho user: $currentUserId và trip: ${widget.tripId}');
    
    // Đảm bảo sắp xếp theo updated_at để lấy bản ghi mới nhất
    final snapshot =
        await FirebaseFirestore.instance
            .collection('user_trip')
            .where('user_id', isEqualTo: currentUserId)
            .where('trip_id', isEqualTo: widget.tripId)
            .orderBy('updated_at', descending: true)
            .get();

    print('Kết quả truy vấn: ${snapshot.docs.length} bản ghi');

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final data = doc.data();
      final checkValue = data['check'];
      final docId = doc.id;
      
      print('Tìm thấy bản ghi: ID=$docId, check=$checkValue, updated_at=${data['updated_at']}');
      
      setState(() {
        userTripStatus = checkValue;
        userTripDocId = docId;
      });
    } else {
      // Nếu chưa có bản ghi, KHÔNG tạo mới ngay mà chỉ đặt trạng thái là null
      print('Không tìm thấy bản ghi cho chuyến đi này');
      setState(() {
        userTripStatus = null;
        userTripDocId = null;
      });
    }
  } catch (e) {
    print('Lỗi khi lấy trạng thái chuyến đi của người dùng: $e');
  }
}

  // Hàm tạo mới user_trip khi người dùng áp dụng lần đầu
  Future<void> createNewUserTrip() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần đăng nhập để áp dụng chuyến đi'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final Timestamp now = Timestamp.now();
      
      // Tạo mới bản ghi user_trip với trạng thái mặc định là đang áp dụng (0)
      final docRef = await FirebaseFirestore.instance
          .collection('user_trip')
          .add({
            'user_id': currentUserId,
            'trip_id': widget.tripId,
            'check': 0,
            'created_at': now,
            'updated_at': now,
          });

      setState(() {
        userTripStatus = 0;
        userTripDocId = docRef.id;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã áp dụng chuyến đi thành công')),
      );
      
      // Cập nhật trạng thái của trip sang đang áp dụng
      if (tripData != null && !tripData!.status) {
        await FirebaseFirestore.instance
            .collection('dia_diem')
            .doc(widget.locationId)
            .collection('trips')
            .doc(widget.tripId)
            .update({'status': true});
        
        setState(() {
          tripData = tripData!.copyWith(status: true);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi áp dụng chuyến đi: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchDayNumbers() async {
    try {
      final snap =
          await FirebaseFirestore.instance
              .collection('dia_diem')
              .doc(widget.locationId)
              .collection('trips')
              .doc(widget.tripId)
              .collection('timelines')
              .orderBy('day_number')
              .get();

      final fetchedDays =
          snap.docs.map((d) => (d.data()['day_number'] as int)).toList();

      setState(() {
        days = fetchedDays;
      });

      // Sau khi lấy số ngày, kiểm tra trạng thái hoàn thành các hoạt động
      await checkAllActivitiesCompleted();
    } catch (e) {
      print('Lỗi khi lấy dữ liệu ngày: $e');
    }
  }

  Future<void> checkAllActivitiesCompleted() async {
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

      for (var day in days) {
        final timelineSnapshots =
            await FirebaseFirestore.instance
                .collection('dia_diem')
                .doc(widget.locationId)
                .collection('trips')
                .doc(widget.tripId)
                .collection('timelines')
                .where('day_number', isEqualTo: day)
                .get();

        for (var timelineDoc in timelineSnapshots.docs) {
          final scheduleSnapshots =
              await timelineDoc.reference.collection('schedule').get();

          totalActivities += scheduleSnapshots.docs.length;

          for (var scheduleDoc in scheduleSnapshots.docs) {
            final data = scheduleDoc.data();
            final status = data['status'] as bool? ?? false;

            if (status) {
              completedCount++;
            } else {
              allCompleted = false;
            }
          }
        }
      }

      setState(() {
        // Cập nhật trạng thái hoàn thành
        allActivitiesCompleted = allCompleted && totalActivities > 0;
        isCheckingActivities = false;
        
        // Sử dụng completedCount để hiển thị thông tin cho người dùng
        // Bạn có thể lưu trữ và hiển thị thông tin này nếu muốn
        print('Hoàn thành: $completedCount/$totalActivities hoạt động');
      });
    } catch (e) {
      print('Lỗi khi kiểm tra hoạt động đã hoàn thành: $e');
      setState(() {
        allActivitiesCompleted = false;
        isCheckingActivities = false;
      });
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
    if (userTripStatus == 1 && newStatus == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể quay lại trạng thái đang áp dụng sau khi đã hoàn thành. Vui lòng sử dụng "Áp dụng lại" để bắt đầu mới.'),
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

      if (userTripDocId != null) {
        // Cập nhật trạng thái nếu đã có bản ghi
        await FirebaseFirestore.instance
            .collection('user_trip')
            .doc(userTripDocId)
            .update({'check': newStatus, 'updated_at': now});

        print('Đã cập nhật trạng thái chuyến đi: $newStatus (DocID: $userTripDocId)');
      } else {
        // Tạo mới nếu chưa có bản ghi
        final docRef = await FirebaseFirestore.instance
            .collection('user_trip')
            .add({
              'user_id': currentUserId,
              'trip_id': widget.tripId,
              'check': newStatus,
              'created_at': now,
              'updated_at': now,
            });

        setState(() {
          userTripDocId = docRef.id;
        });

        print('Đã tạo mới trạng thái chuyến đi: $newStatus (DocID: ${docRef.id})');
      }

      setState(() {
        userTripStatus = newStatus;
      });

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
        SnackBar(content: Text('Chuyến đi đã được cập nhật thành $statusText')),
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

  // Chuyển đến trang đánh giá hoặc tạo đánh giá mới
  Future<void> _navigateToReview(int tripStatus) async {
    if (tripData == null) return;

    final locationSnapshot =
        await FirebaseFirestore.instance
            .collection('dia_diem')
            .doc(widget.locationId)
            .get();

    if (!locationSnapshot.exists) return;

    final locationData = locationSnapshot.data() as Map<String, dynamic>;
    final locationName = locationData['ten'] as String? ?? 'Không xác định';

    // Tạo đối tượng review
    final reviewData = {
      'trip_id': widget.tripId,
      'location': locationName,
      'duration':
          '${tripData!.soNgay} ngày ${tripData!.soNgay > 1 ? (tripData!.soNgay - 1) : 0} đêm',
      'rating': 0,
      'comment': '',
      'imageUrl': locationData['hinh_anh1'] ?? 'assets/images/vungtau.png',
      'accommodation': tripData!.noiO,
      'price': tripData!.chiPhi,
      'people': tripData!.soNguoi,
    };

    // Kiểm tra nếu người dùng đã có đánh giá cho chuyến đi này
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final existingReviewSnapshot =
        await FirebaseFirestore.instance
            .collection('reviews')
            .where('user_id', isEqualTo: currentUserId)
            .where('trip_id', isEqualTo: widget.tripId)
            .get();

    // Nếu người dùng đã hoàn thành chuyến đi, hỏi xem có muốn đánh giá ngay không
    if (tripStatus == 1 && existingReviewSnapshot.docs.isEmpty) {
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
                      child: const Text('Để sau'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Đánh giá ngay'),
                    ),
                  ],
                ),
          ) ??
          false;

      if (shouldReview) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => EditReviewScreen(
                  review: reviewData,
                  isNewReview: true,
                  userId: currentUserId,
                ),
          ),
        );

        // Cập nhật lại trạng thái đánh giá sau khi quay về
        await checkIfReviewed();
      }
    }
  }

  // Phương thức nâng cao để chuyển đến trang đánh giá
  void _navigateToReviewScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReviewListView()),
    ).then((_) {
      // Refresh data when returning from review screen
      setState(() {
        _initDataFuture = _initializeData();
      });
    });
  }
  
  // Phương thức tạo đánh giá mới
  Future<void> _createNewReview() async {
    if (tripData == null) return;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final locationSnapshot =
        await FirebaseFirestore.instance
            .collection('dia_diem')
            .doc(widget.locationId)
            .get();

    if (!locationSnapshot.exists) return;

    final locationData = locationSnapshot.data() as Map<String, dynamic>;
    final locationName = locationData['ten'] as String? ?? 'Không xác định';

    // Tạo đối tượng review
    final reviewData = {
      'trip_id': widget.tripId,
      'location': locationName,
      'duration':
          '${tripData!.soNgay} ngày ${tripData!.soNgay > 1 ? (tripData!.soNgay - 1) : 0} đêm',
      'rating': 0,
      'comment': '',
      'imageUrl': locationData['hinh_anh1'] ?? 'assets/images/vungtau.png',
      'accommodation': tripData!.noiO,
      'price': tripData!.chiPhi,
      'people': tripData!.soNguoi,
    };

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReviewScreen(
          review: reviewData,
          isNewReview: true,
          userId: currentUserId,
        ),
      ),
    );

    // Cập nhật lại trạng thái đánh giá sau khi quay về
    await checkIfReviewed();
  }

  // Method to reset trip progress
  Future<void> _resetTripProgress() async {
    // Show confirmation dialog
    bool confirm =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Áp dụng lại'),
                content: const Text(
                  'Bạn có chắc chắn muốn áp dụng lại chuyến đi này? Tất cả tiến độ sẽ được làm mới.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Hủy'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Xác nhận'),
                  ),
                ],
              ),
        ) ??
        false;

    if (!confirm) return;

    setState(() {
      isLoading = true;
    });

    try {
      // 1. Reset all activity statuses to false
      final timelines =
          await FirebaseFirestore.instance
              .collection('dia_diem')
              .doc(widget.locationId)
              .collection('trips')
              .doc(widget.tripId)
              .collection('timelines')
              .get();

      for (var timeline in timelines.docs) {
        final schedules = await timeline.reference.collection('schedule').get();

        for (var schedule in schedules.docs) {
          await schedule.reference.update({'status': false});
        }
      }

      // 2. Update user_trip status to "applying" (0)
      await FirebaseFirestore.instance
          .collection('user_trip')
          .doc(userTripDocId)
          .update({'check': 0, 'updated_at': Timestamp.now()});

      setState(() {
        userTripStatus = 0;
        allActivitiesCompleted = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã áp dụng lại chuyến đi thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi áp dụng lại: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onSetPeople(int newCount) {
    if (tripData != null) {
      setState(() {
        tripData = tripData!.copyWith(soNguoi: newCount);
      });
    }
  }

  void onSetCost(int newCost) {
    if (tripData != null) {
      setState(() {
        tripData = tripData!.copyWith(chiPhi: newCost);
      });
    }
  }

  void onChangeDate(DateTime newDate) {
    setState(() {
      initDate = newDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (tripData == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang tải dữ liệu chuyến đi...'),
              ],
            ),
          );
        }

        // In ra trạng thái cho việc debug
        print('Rendering with userTripStatus: $userTripStatus');

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TripCard(trip: tripData!),
              SetPeopleNum(
                peopleNum: tripData!.soNguoi,
                cost: tripData!.chiPhi,
                onSetPeople: onSetPeople,
                onSetCost: onSetCost,
                diaDiemId: widget.locationId,
                tripId: widget.tripId,
              ),
              SetDayStart(
                dateStart: initDate,
                numberDay: tripData!.soNgay,
                onChangeDate: onChangeDate,
                locationId: widget.locationId,
                tripId: widget.tripId,
              ),
              const SizedBox(height: 16),
              
              // Hiển thị tiến độ hoàn thành các hoạt động
              if (isCheckingActivities)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (days.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        'Trạng thái hoạt động: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(MyColor.black),
                        ),
                      ),
                      Icon(
                        allActivitiesCompleted
                            ? Icons.check_circle
                            : Icons.info_outline,
                        color:
                            allActivitiesCompleted
                                ? Colors.green
                                : Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        allActivitiesCompleted
                            ? 'Đã hoàn thành tất cả'
                            : 'Chưa hoàn thành tất cả',
                        style: TextStyle(
                          color:
                              allActivitiesCompleted
                                  ? Colors.green
                                  : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              if (days.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Không có lịch trình cho ngày nào'),
                )
              else
                ...days.map((day) {
                  final query = FirebaseFirestore.instance
                      .collection('dia_diem')
                      .doc(widget.locationId)
                      .collection('trips')
                      .doc(widget.tripId)
                      .collection('timelines')
                      .where('day_number', isEqualTo: day);

                  return TimelineList(
                    numberDay: day,
                    timelineQuery: query,
                    locationId: widget.locationId,
                    tripId: widget.tripId,
                    onActivityStatusChanged: () {
                      // Khi trạng thái hoạt động thay đổi, kiểm tra lại
                      checkAllActivitiesCompleted();
                    },
                  );
                }),

              // Nút cập nhật trạng thái chuyến đi
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Hiển thị tiêu đề khác nhau dựa trên trạng thái chuyến đi
                    if (userTripStatus == null)
                      Text(
                        'Bắt đầu hành trình của bạn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(MyColor.pr5),
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
                        child: isLoading 
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
                            onPressed: (isLoading) ? null : () => updateTripStatus(0),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(MyColor.pr3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
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
                            onPressed: (isLoading || !allActivitiesCompleted)
                                ? null
                                : () => updateTripStatus(1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(MyColor.white),
                              foregroundColor: Color(MyColor.pr5),
                              side: BorderSide(color: Color(MyColor.pr5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              disabledBackgroundColor: Color(MyColor.white).withOpacity(0.5),
                              disabledForegroundColor: Color(MyColor.pr5).withOpacity(0.5),
                            ),
                            child: const Text('Hoàn thành'),
                          ),
                          ElevatedButton(
                            onPressed: (isLoading) ? null : () => updateTripStatus(2),
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
                            icon: Icon(
                              Icons.refresh,
                              color: Color(MyColor.pr5),
                            ),
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
                    if (tripData?.status != null && userTripStatus == 0)
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                try {
                                  final newStatus = !tripData!.status;
                                  await FirebaseFirestore.instance
                                      .collection('dia_diem')
                                      .doc(widget.locationId)
                                      .collection('trips')
                                      .doc(widget.tripId)
                                      .update({'status': newStatus});

                                  setState(() {
                                    tripData = tripData!.copyWith(
                                      status: newStatus,
                                    );
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        newStatus
                                            ? 'Đã bắt đầu hành trình'
                                            : 'Đã tạm dừng hành trình',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Lỗi khi cập nhật: $e'),
                                    ),
                                  );
                                }
                              },
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
                        child: Text(
                          tripData!.status ? 'Dừng hành trình' : 'Bắt đầu hành trình',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}