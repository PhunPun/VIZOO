import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TripDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache để tránh truy vấn lặp lại
  final Map<String, Map<String, dynamic>> _tripsCache = {};
  final Map<String, Map<String, dynamic>> _locationsCache = {};
  final Map<String, double> _ratingsCache = {};

  // Lấy thông tin trip từ bảng selected_trips và user_trip
  Future<List<Map<String, dynamic>>> getUserTrips({
    required int tripStatus, // 0: đang áp dụng, 1: hoàn thành, 2: đã hủy
  }) async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (currentUserId.isEmpty) return [];

      print(
        'Đang lấy danh sách các chuyến đi với trạng thái: $tripStatus cho user: $currentUserId',
      );

      // Truy vấn user_trip trước để lấy tất cả chuyến đi của người dùng
      final userTripSnapshot =
          await _firestore
              .collection('user_trip')
              .where('user_id', isEqualTo: currentUserId)
              .where('check', isEqualTo: tripStatus)
              .get();

      if (userTripSnapshot.docs.isEmpty) {
        print('Không tìm thấy chuyến đi nào với trạng thái: $tripStatus');
        return [];
      }

      print('Tìm thấy ${userTripSnapshot.docs.length} chuyến đi từ user_trip');

      List<Map<String, dynamic>> trips = [];

      // Xử lý từng chuyến đi
      for (var doc in userTripSnapshot.docs) {
        final tripData = doc.data();
        final tripId = tripData['trip_id'] as String? ?? '';
        final seTripId = tripData['se_trip_id'] as String? ?? '';

        if (tripId.isEmpty) continue;

        // Xác định location_id từ tripId nếu cần
        String locationId = '';
        final idParts = tripId.split('_');
        if (idParts.length > 1) {
          locationId = idParts[0];
        }

        // Lấy thông tin từ selected_trips nếu có seTripId
        Map<String, dynamic> seTripData = {};
        if (seTripId.isNotEmpty) {
          try {
            final seTripDoc =
                await _firestore
                    .collection('users')
                    .doc(currentUserId)
                    .collection('selected_trips')
                    .doc(seTripId)
                    .get();

            if (seTripDoc.exists) {
              seTripData = seTripDoc.data() ?? {};

              // Nếu có location_id trong selected_trips, sử dụng nó
              if (seTripData.containsKey('location_id') &&
                  seTripData['location_id'].toString().isNotEmpty) {
                locationId = seTripData['location_id'];
              }
            }
          } catch (e) {
            print('Lỗi khi đọc selected_trip $seTripId: $e');
          }
        }

        // Lấy thông tin vị trí từ cache hoặc Firestore
        Map<String, dynamic> locationData = {};
        if (locationId.isNotEmpty) {
          if (_locationsCache.containsKey(locationId)) {
            locationData = _locationsCache[locationId]!;
          } else {
            try {
              final locationDoc =
                  await _firestore.collection('dia_diem').doc(locationId).get();
              if (locationDoc.exists) {
                locationData = locationDoc.data() ?? {};
                _locationsCache[locationId] = locationData;
              }
            } catch (e) {
              print('Lỗi khi lấy thông tin địa điểm $locationId: $e');
            }
          }
        }

        // Kết hợp dữ liệu
        Map<String, dynamic> combinedData = {...seTripData, ...tripData};

        // Đọc hoặc đếm số hoạt động và bữa ăn
        int activities = _extractIntValue(seTripData, 'so_act', 0);
        int meals = _extractIntValue(seTripData, 'so_eat', 0);

        if (activities == 0 || meals == 0) {
          final counts = await _getActivityAndMealCounts(
            currentUserId,
            seTripId,
            locationId,
          );
          if (activities == 0) activities = counts['activities'] ?? 0;
          if (meals == 0) meals = counts['meals'] ?? 0;
        }

        // Lấy hình ảnh
        String imageUrl = 'assets/images/vungtau.png'; // Mặc định
        if (seTripData.containsKey('anh') &&
            seTripData['anh'].toString().isNotEmpty) {
          imageUrl = seTripData['anh'].toString();
        } else if (locationData.containsKey('hinh_anh1') &&
            locationData['hinh_anh1'].toString().isNotEmpty) {
          imageUrl = locationData['hinh_anh1'].toString();
        }

        // Format ngày
        String dateText = _formatDateFromTimestamp(combinedData);

        // Xử lý các trường dữ liệu cơ bản
        int soDays = _extractIntValue(combinedData, 'so_ngay', 1);
        String accommodation =
            combinedData['noi_o']?.toString() ?? 'Không xác định';
        int people = _extractIntValue(combinedData, 'so_nguoi', 1);
        int price = _extractIntValue(combinedData, 'chi_phi', 0);

        // Tạo đối tượng trip
        Map<String, dynamic> tripInfo = {
          'trip_id': tripId,
          'location_id': locationId,
          'se_trip_id': seTripId,
          'location': locationData['ten'] ?? 'Không xác định',
          'duration': '$soDays ngày ${soDays > 1 ? (soDays - 1) : 0} đêm',
          'activities': activities,
          'meals': meals,
          'people': people,
          'accommodation': accommodation,
          'price': price,
          'imageUrl': imageUrl,
          'userTripDocId': doc.id,
        };

        // Thêm thông tin trạng thái
        if (tripStatus == 1) {
          // Hoàn thành
          tripInfo['completion_date'] = dateText;

          // Thêm thông tin đánh giá nếu có
          await _addReviewInfo(tripInfo, currentUserId, tripId);
        } else if (tripStatus == 2) {
          // Đã hủy
          tripInfo['cancelled_date'] = dateText;
        }

        trips.add(tripInfo);
      }

      return trips;
    } catch (e) {
      print('Lỗi khi lấy danh sách chuyến đi: $e');
      return [];
    }
  }

  // Trích xuất giá trị int từ Map
  int _extractIntValue(
    Map<String, dynamic> data,
    String key,
    int defaultValue,
  ) {
    if (!data.containsKey(key) || data[key] == null) return defaultValue;

    if (data[key] is int) return data[key];
    return int.tryParse(data[key].toString()) ?? defaultValue;
  }

  // Format ngày từ Timestamp
  String _formatDateFromTimestamp(Map<String, dynamic> data) {
    Timestamp? timestamp;
    final possibleFields = [
      'updated_at',
      'completed_at',
      'cancelled_at',
      'created_at',
    ];

    for (var field in possibleFields) {
      if (data.containsKey(field) && data[field] is Timestamp) {
        timestamp = data[field] as Timestamp;
        break;
      }
    }

    if (timestamp != null) {
      return DateFormat('dd/MM/yyyy').format(timestamp.toDate());
    }

    return 'Không xác định';
  }

  // Đếm số lượng hoạt động và bữa ăn từ timelines
  Future<Map<String, int>> _getActivityAndMealCounts(
    String userId,
    String seTripId,
    String locationId,
  ) async {
    int activities = 0;
    int meals = 0;

    if (userId.isEmpty || seTripId.isEmpty) {
      return {'activities': 0, 'meals': 0};
    }

    try {
      final timelinesRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('selected_trips')
          .doc(seTripId)
          .collection('timelines');

      final timelinesSnapshot = await timelinesRef.get();

      for (var timeline in timelinesSnapshot.docs) {
        final schedulesSnapshot =
            await timeline.reference.collection('schedule').get();

        activities += schedulesSnapshot.docs.length;

        // Kiểm tra bữa ăn nếu có location_id
        if (locationId.isNotEmpty) {
          for (var schedule in schedulesSnapshot.docs) {
            final actId = schedule.data()['act_id'] as String?;
            if (actId == null || actId.isEmpty) continue;

            try {
              final activityDoc =
                  await _firestore
                      .collection('dia_diem')
                      .doc(locationId)
                      .collection('activities')
                      .doc(actId)
                      .get();

              if (activityDoc.exists) {
                final categories = activityDoc.data()?['categories'] as String?;
                if (categories == 'eat') {
                  meals++;
                }
              }
            } catch (e) {
              // Bỏ qua lỗi để không ảnh hưởng đến quy trình
            }
          }
        }
      }

      // Cập nhật vào selected_trips nếu cần
      if (activities > 0 || meals > 0) {
        try {
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('selected_trips')
              .doc(seTripId)
              .update({
                if (activities > 0) 'so_act': activities,
                if (meals > 0) 'so_eat': meals,
              });
        } catch (e) {
          print('Lỗi khi cập nhật số lượng hoạt động và bữa ăn: $e');
        }
      }

      return {'activities': activities, 'meals': meals};
    } catch (e) {
      print('Lỗi khi đếm hoạt động và bữa ăn: $e');
      return {'activities': 0, 'meals': 0};
    }
  }

  // Thêm thông tin đánh giá vào trip
  Future<void> _addReviewInfo(
    Map<String, dynamic> tripInfo,
    String userId,
    String tripId,
  ) async {
    try {
      final reviewsSnapshot =
          await _firestore
              .collection('reviews')
              .where('user_id', isEqualTo: userId)
              .where('trip_id', isEqualTo: tripId)
              .limit(1)
              .get();

      if (reviewsSnapshot.docs.isNotEmpty) {
        final reviewDoc = reviewsSnapshot.docs.first;
        final reviewData = reviewDoc.data();

        int rating = 0;
        final votesData = reviewData['votes'];

        if (votesData != null) {
          if (votesData is int) {
            rating = votesData;
          } else {
            rating = int.tryParse(votesData.toString()) ?? 0;
          }
        }

        tripInfo['rating'] = rating;
        tripInfo['review_id'] = reviewDoc.id;
        tripInfo['comment'] = reviewData['comment'] ?? '';
      } else {
        tripInfo['rating'] = 0;
        tripInfo['review_id'] = '';
        tripInfo['comment'] = '';
      }

      // Thêm đánh giá trung bình
      final avgRating = await getTripAverageRating(tripId);
      tripInfo['averageRating'] = avgRating;
    } catch (e) {
      print('Lỗi khi thêm thông tin đánh giá: $e');
      tripInfo['rating'] = 0;
      tripInfo['review_id'] = '';
      tripInfo['comment'] = '';
    }
  }

  void clearCache() {
    _tripsCache.clear();
    _locationsCache.clear();
    _ratingsCache.clear();
  }

  // Cập nhật số lượng hoạt động và bữa ăn
  Future<void> updateActivityAndMealCounts(String seTripId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null || seTripId.isEmpty) return;

      final seTripDoc =
          await _firestore
              .collection('users')
              .doc(currentUserId)
              .collection('selected_trips')
              .doc(seTripId)
              .get();

      if (!seTripDoc.exists) return;

      final seTripData = seTripDoc.data() ?? {};
      final locationId = seTripData['location_id'] as String? ?? '';

      final counts = await _getActivityAndMealCounts(
        currentUserId,
        seTripId,
        locationId,
      );

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('selected_trips')
          .doc(seTripId)
          .update({
            'so_act': counts['activities'],
            'so_eat': counts['meals'],
            'updated_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Lỗi khi cập nhật số lượng hoạt động và bữa ăn: $e');
    }
  }

  // Lấy danh sách đánh giá của người dùng
  Future<List<Map<String, dynamic>>> getUserReviews() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (currentUserId.isEmpty) return [];

      // Lấy đánh giá từ reviews collection
      final reviewsSnapshot =
          await _firestore
              .collection('reviews')
              .where('user_id', isEqualTo: currentUserId)
              .get();

      final List<Map<String, dynamic>> reviews = [];

      for (var doc in reviewsSnapshot.docs) {
        final reviewData = doc.data();
        final Map<String, dynamic> reviewInfo = {'id': doc.id, ...reviewData};

        // Kiểm tra và thêm các trường từ trip_details nếu có
        if (reviewData.containsKey('trip_details') &&
            reviewData['trip_details'] is Map) {
          final tripDetails = Map<String, dynamic>.from(
            reviewData['trip_details'],
          );
          reviewInfo.addAll(tripDetails);
        }

        reviews.add(reviewInfo);
      }

      return reviews;
    } catch (e) {
      print('Lỗi khi lấy đánh giá: $e');
      return [];
    }
  }

  // Lấy danh sách các chuyến đi đã hoàn thành nhưng chưa đánh giá
  Future<List<Map<String, dynamic>>> getPendingReviews() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (currentUserId.isEmpty) return [];

      // Xóa cache để đảm bảo lấy dữ liệu mới nhất
      _tripsCache.clear();
      _ratingsCache.clear();

      // 1. Lấy tất cả chuyến đi đã hoàn thành
      final completedTrips = await getUserTrips(tripStatus: 1);
      if (completedTrips.isEmpty) return [];

      // 2. Lấy danh sách các trip_id đã được đánh giá - KHÔNG dùng cache
      final reviewsSnapshot =
          await _firestore
              .collection('reviews')
              .where('user_id', isEqualTo: currentUserId)
              .get();

      final Set<String> reviewedTripIds =
          reviewsSnapshot.docs
              .map((doc) => doc.data()['trip_id'] as String? ?? '')
              .where((id) => id.isNotEmpty)
              .toSet();

      print(
        'Đã tìm thấy ${reviewedTripIds.length} trip đã được đánh giá: $reviewedTripIds',
      );

      // 3. Lọc ra các chuyến đi chưa được đánh giá
      final List<Map<String, dynamic>> pendingReviews =
          completedTrips
              .where((trip) => !reviewedTripIds.contains(trip['trip_id']))
              .toList();

      print('Có ${pendingReviews.length} chuyến đi cần đánh giá');
      return pendingReviews;
    } catch (e) {
      print('Lỗi khi lấy danh sách chuyến đi cần đánh giá: $e');
      return [];
    }
  }

  // Lấy danh sách đánh giá của người dùng khác
  // Lấy danh sách đánh giá của người dùng khác
  Future<List<Map<String, dynamic>>> getOtherUserReviews(String tripId) async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Lấy tất cả đánh giá của trip
      final reviewsSnapshot =
          await _firestore
              .collection('reviews')
              .where('trip_id', isEqualTo: tripId)
              .get();

      if (reviewsSnapshot.docs.isEmpty) {
        return [];
      }

      // Lọc và bổ sung thông tin người dùng
      final otherReviews = <Map<String, dynamic>>[];

      for (var doc in reviewsSnapshot.docs) {
        final data = doc.data();
        final userId = data['user_id'] as String? ?? '';

        if (userId != currentUserId) {
          // Lấy thông tin người dùng
          String userName = 'Người dùng khác';
          try {
            final userDoc =
                await _firestore.collection('users').doc(userId).get();
            if (userDoc.exists) {
              final userData = userDoc.data();
              userName =
                  userData?['fullname'] ??
                  userData?['email'] ??
                  userData?['displayName'] ??
                  'Người dùng khác';
            }
          } catch (e) {
            print('Lỗi khi lấy thông tin người dùng: $e');
          }

          // Format ngày
          String reviewDate = '';
          if (data.containsKey('created_at') &&
              data['created_at'] is Timestamp) {
            final timestamp = data['created_at'] as Timestamp;
            reviewDate = DateFormat('dd/MM/yyyy').format(timestamp.toDate());
          }

          otherReviews.add({
            'id': doc.id,
            ...data,
            'userName': userName,
            'formattedDate': reviewDate,
          });
        }
      }

      return otherReviews;
    } catch (e) {
      print('Lỗi khi lấy đánh giá của người dùng khác: $e');
      return [];
    }
  }

  // Lấy điểm đánh giá trung bình
  Future<double> getTripAverageRating(String tripId) async {
    try {
      // Kiểm tra cache
      if (_ratingsCache.containsKey(tripId)) {
        return _ratingsCache[tripId]!;
      }

      // Lấy tất cả đánh giá của trip
      final reviewsSnapshot =
          await _firestore
              .collection('reviews')
              .where('trip_id', isEqualTo: tripId)
              .get();

      if (reviewsSnapshot.docs.isEmpty) {
        _ratingsCache[tripId] = 0.0;
        return 0.0;
      }

      // Tính tổng số đánh giá và điểm
      double totalRating = 0.0;
      int count = 0;

      for (var doc in reviewsSnapshot.docs) {
        final votes = doc.data()['votes'];

        if (votes != null) {
          double rating = 0.0;
          if (votes is int) {
            rating = votes.toDouble();
          } else if (votes is String) {
            rating = double.tryParse(votes) ?? 0.0;
          } else if (votes is double) {
            rating = votes;
          } else {
            rating = double.tryParse(votes.toString()) ?? 0.0;
          }

          if (rating > 0) {
            totalRating += rating;
            count++;
          }
        }
      }

      final double averageRating = count > 0 ? totalRating / count : 0.0;
      _ratingsCache[tripId] = averageRating;

      return averageRating;
    } catch (e) {
      print('Lỗi khi tính điểm đánh giá trung bình: $e');
      return 0.0;
    }
  }
}
