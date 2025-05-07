import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TripDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Cache for location and trip data to improve performance
  static final Map<String, Map<String, dynamic>> _locationsCache = {};
  static final Map<String, Map<String, dynamic>> _tripsCache = {};
  static final Map<String, double> _ratingsCache = {};
  
  // Get location by ID with caching
  Future<Map<String, dynamic>> getLocationById(String locationId) async {
    if (_locationsCache.containsKey(locationId)) {
      return _locationsCache[locationId]!;
    }
    
    try {
      final doc = await _firestore.collection('dia_diem').doc(locationId).get();
      if (doc.exists) {
        final data = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
        _locationsCache[locationId] = data;
        return data;
      }
    } catch (e) {
      print('Error fetching location $locationId: $e');
    }
    
    return {'id': locationId, 'ten': 'Không xác định'};
  }
  
  // Get trip details by ID with caching
  Future<Map<String, dynamic>> getTripById(String tripId, {String? locationId}) async {
    if (_tripsCache.containsKey(tripId)) {
      return _tripsCache[tripId]!;
    }
    
    try {
      // If we know the location ID, try that first
      if (locationId != null && locationId.isNotEmpty) {
        final tripDoc = await _firestore
            .collection('dia_diem')
            .doc(locationId)
            .collection('trips')
            .doc(tripId)
            .get();
            
        if (tripDoc.exists) {
          final data = tripDoc.data() as Map<String, dynamic>;
          _tripsCache[tripId] = data;
          return data;
        }
      }
      
      // If location ID is not provided or trip not found, search in all locations
      final locationDocs = await _firestore.collection('dia_diem').get();
      for (var locationDoc in locationDocs.docs) {
        final tripDoc = await _firestore
            .collection('dia_diem')
            .doc(locationDoc.id)
            .collection('trips')
            .doc(tripId)
            .get();
            
        if (tripDoc.exists) {
          final data = tripDoc.data() as Map<String, dynamic>;
          _tripsCache[tripId] = data;
          return data;
        }
      }
    } catch (e) {
      print('Error fetching trip $tripId: $e');
    }
    
    return {};
  }
  
  // Get a specific review
  Future<Map<String, dynamic>> getReviewById(String reviewId) async {
    try {
      final doc = await _firestore.collection('reviews').doc(reviewId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }
    } catch (e) {
      print('Error fetching review $reviewId: $e');
    }
    
    return {};
  }
  
  // Lấy thông tin trip từ bảng selected_trips, user_trip và dia_diem
  Future<List<Map<String, dynamic>>> getUserTrips({
    required int tripStatus, // 0: đang áp dụng, 1: hoàn thành, 2: đã hủy
  }) async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (currentUserId.isEmpty) return [];

      print('Đang lấy danh sách các chuyến đi với trạng thái: $tripStatus cho user: $currentUserId');
      
      // Lấy danh sách các selected_trips trước
      final selectedTripsSnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('selected_trips')
          .where('check', isEqualTo: tripStatus)
          .get();

      // Lấy danh sách các chuyến đi từ user_trip
      final userTripSnapshot = await _firestore
          .collection('user_trip')
          .where('user_id', isEqualTo: currentUserId)
          .where('check', isEqualTo: tripStatus)
          .where('se_trip_id')
          .get();
          
      // Nếu không có dữ liệu nào, trả về danh sách rỗng
      if (selectedTripsSnapshot.docs.isEmpty && userTripSnapshot.docs.isEmpty) {
        print('Không tìm thấy chuyến đi nào với trạng thái: $tripStatus');
        return [];
      }
      
      // Map để lưu trữ thông tin chuyến đi theo tripId
      final Map<String, Map<String, dynamic>> tripsMap = {};
      
      // Xử lý dữ liệu từ selected_trips
      for (var doc in selectedTripsSnapshot.docs) {
        final tripId = doc.data()['se_trip_id'] as String? ?? doc.id;
        final locationId = doc.data()['location_id'] as String? ?? '';
        
        if (tripId.isEmpty) continue;
        
        tripsMap[tripId] = {
          'trip_id': tripId,
          'location_id': locationId,
          'se_trip_id': doc.id,
          'check': tripStatus,
          ...doc.data(),
        };
      }
      
      // Bổ sung thông tin từ user_trip
      for (var doc in userTripSnapshot.docs) {
        final tripId = doc.data()['trip_id'] as String? ?? '';
        final seTripId = doc.data()['se_trip_id'] as String? ?? '';
        
        if (tripId.isEmpty) continue;
        
        // Nếu đã có trong map, bổ sung thông tin
        if (tripsMap.containsKey(tripId)) {
          tripsMap[tripId]!.addAll({
            'userTripDocId': doc.id,
            'se_trip_id': seTripId.isNotEmpty ? seTripId : tripsMap[tripId]!['se_trip_id'],
          });
        } else {
          // Chưa có trong map, thêm mới
          tripsMap[tripId] = {
            'trip_id': tripId,
            'userTripDocId': doc.id,
            'se_trip_id': seTripId,
            'check': tripStatus,
            ...doc.data(),
          };
        }
      }
      
      // Chuyển đổi Map thành List
      List<Map<String, dynamic>> trips = tripsMap.values.toList();
      
      // Đảm bảo có đầy đủ thông tin cho từng chuyến đi
      List<Map<String, dynamic>> enrichedTrips = [];
      
      for (var trip in trips) {
        try {
          final enrichedTrip = await _enrichTripData(trip, tripStatus);
          if (enrichedTrip.isNotEmpty) {
            enrichedTrips.add(enrichedTrip);
          }
        } catch (e) {
          print('Lỗi khi làm giàu dữ liệu cho trip ${trip['trip_id']}: $e');
        }
      }
      
      return enrichedTrips;
    } catch (e) {
      print('Lỗi khi lấy danh sách chuyến đi: $e');
      return [];
    }
  }
  
  // Phương thức để làm giàu dữ liệu cho một trip
  Future<Map<String, dynamic>> _enrichTripData(
    Map<String, dynamic> trip,
    int tripStatus
  ) async {
    final String tripId = trip['se_trip_id'] as String? ?? '';
    if (tripId.isEmpty) return {};
    
    // Xác định location_id
    String locationId = trip['location_id'] as String? ?? '';
    
    // Tìm location_id từ tripId nếu chưa có
    if (locationId.isEmpty && tripId.contains('_')) {
      final parts = tripId.split('_');
      if (parts.length > 1) {
        locationId = parts[0];
      }
    }
    
    // Nếu vẫn không có locationId, tìm kiếm trong tất cả các địa điểm
    if (locationId.isEmpty) {
      try {
        final locationDocs = await _firestore.collection('dia_diem').get();
        for (var locationDoc in locationDocs.docs) {
          final tripExists = await _firestore
              .collection('dia_diem')
              .doc(locationDoc.id)
              .collection('trips')
              .doc(tripId)
              .get();
              
          if (tripExists.exists) {
            locationId = locationDoc.id;
            break;
          }
        }
      } catch (e) {
        print('Lỗi khi tìm locationId: $e');
      }
    }
    
    // Lấy thông tin địa điểm
    Map<String, dynamic> locationData = {};
    if (locationId.isNotEmpty) {
      locationData = await getLocationById(locationId);
    }
    
    // Lấy thông tin từ master trip
    Map<String, dynamic> tripData = {};
    if (locationId.isNotEmpty) {
      tripData = await getTripById(tripId, locationId: locationId);
    }
    
    // Lấy thông tin từ selected_trip (nếu có)
    Map<String, dynamic> selectedTripData = {};
    final String seTripId = trip['se_trip_id'] as String? ?? '';
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    if (seTripId.isNotEmpty && currentUserId.isNotEmpty) {
      try {
        final seTripDoc = await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('selected_trips')
            .doc(seTripId)
            .get();
            
        if (seTripDoc.exists) {
          selectedTripData = seTripDoc.data() ?? {};
        }
      } catch (e) {
        print('Lỗi khi lấy dữ liệu từ selected_trip: $e');
      }
    }
    
    // Đếm hoạt động và bữa ăn
    int activities = 0;
    int meals = 0;
    
    // Ưu tiên đọc từ metadata của selected_trip
    if (selectedTripData.isNotEmpty) {
      activities = selectedTripData['so_act'] is int 
          ? selectedTripData['so_act'] 
          : int.tryParse(selectedTripData['so_act']?.toString() ?? '0') ?? 0;
          
      meals = selectedTripData['so_eat'] is int 
          ? selectedTripData['so_eat'] 
          : int.tryParse(selectedTripData['so_eat']?.toString() ?? '0') ?? 0;
    }
    
    // Nếu không có từ metadata, đếm trực tiếp từ timeline
    if ((activities == 0 || meals == 0) && seTripId.isNotEmpty && currentUserId.isNotEmpty) {
      try {
        final counts = await _countActivitiesAndMeals(
          userId: currentUserId,
          seTripId: seTripId,
          locationId: locationId
        );
        
        if (activities == 0) activities = counts['activities'] ?? 0;
        if (meals == 0) meals = counts['meals'] ?? 0;
        
        // Cập nhật lại metadata nếu cần
        if ((counts['activities'] ?? 0) > 0 || (counts['meals'] ?? 0) > 0) {
          try {
            await _firestore
                .collection('users')
                .doc(currentUserId)
                .collection('selected_trips')
                .doc(seTripId)
                .update({
                  'so_act': counts['activities'] ?? FieldValue.delete(),
                  'so_eat': counts['meals'] ?? FieldValue.delete(),
                  'updated_at': FieldValue.serverTimestamp(),
                });
          } catch (e) {
            print('Lỗi khi cập nhật metadata: $e');
          }
        }
      } catch (e) {
        print('Lỗi khi đếm hoạt động và bữa ăn: $e');
      }
    }
    
    // Nếu vẫn không có, sử dụng dữ liệu từ trip
    if (activities == 0 && tripData.containsKey('so_act')) {
      activities = tripData['so_act'] is int 
          ? tripData['so_act'] 
          : int.tryParse(tripData['so_act']?.toString() ?? '0') ?? 0;
    }
    
    if (meals == 0 && tripData.containsKey('so_eat')) {
      meals = tripData['so_eat'] is int 
          ? tripData['so_eat'] 
          : int.tryParse(tripData['so_eat']?.toString() ?? '0') ?? 0;
    }
    
    // Tìm hình ảnh với thứ tự ưu tiên
    String imageUrl = 'assets/images/vungtau.png'; // Mặc định
    
    if (selectedTripData.containsKey('anh') && 
        selectedTripData['anh'] != null && 
        selectedTripData['anh'].toString().isNotEmpty) {
      imageUrl = selectedTripData['anh'].toString();
    } else if (tripData.containsKey('anh') && 
              tripData['anh'] != null && 
              tripData['anh'].toString().isNotEmpty) {
      imageUrl = tripData['anh'].toString();
    } else if (locationData.containsKey('hinh_anh1') && 
              locationData['hinh_anh1'] != null && 
              locationData['hinh_anh1'].toString().isNotEmpty) {
      imageUrl = locationData['hinh_anh1'].toString();
    }
    
    // Lấy ngày tháng từ timestamp
    String dateText = 'Không xác định';
    Timestamp? timestamp;
    
    if (tripStatus == 1) { // Hoàn thành
      timestamp = trip['completed_at'] as Timestamp? ?? 
                trip['updated_at'] as Timestamp?;
    } else if (tripStatus == 2) { // Đã hủy
      timestamp = trip['cancelled_at'] as Timestamp? ?? 
                trip['updated_at'] as Timestamp?;
    } else {
      timestamp = trip['updated_at'] as Timestamp?;
    }
    
    if (timestamp != null) {
      final date = timestamp.toDate();
      dateText = DateFormat('dd/MM/yyyy').format(date);
    }
    
    // Lấy thông tin số ngày
    int soDays = 0;
    if (selectedTripData.containsKey('so_ngay')) {
      soDays = selectedTripData['so_ngay'] is int
          ? selectedTripData['so_ngay']
          : int.tryParse(selectedTripData['so_ngay'].toString()) ?? 0;
    } else if (tripData.containsKey('so_ngay')) {
      soDays = tripData['so_ngay'] is int
          ? tripData['so_ngay']
          : int.tryParse(tripData['so_ngay'].toString()) ?? 0;
    }
    
    // Nơi ở và giá
    String accommodation = selectedTripData['noi_o']?.toString() ?? 
                         tripData['noi_o']?.toString() ?? 
                         'Không xác định';
    
    int price = 0;
    if (selectedTripData.containsKey('chi_phi')) {
      price = selectedTripData['chi_phi'] is int 
          ? selectedTripData['chi_phi'] 
          : int.tryParse(selectedTripData['chi_phi'].toString()) ?? 0;
    } else if (tripData.containsKey('chi_phi')) {
      price = tripData['chi_phi'] is int 
          ? tripData['chi_phi'] 
          : int.tryParse(tripData['chi_phi'].toString()) ?? 0;
    }
    
    // Số người
    int people = 1;
    if (selectedTripData.containsKey('so_nguoi')) {
      people = selectedTripData['so_nguoi'] is int 
          ? selectedTripData['so_nguoi'] 
          : int.tryParse(selectedTripData['so_nguoi'].toString()) ?? 1;
    } else if (tripData.containsKey('so_nguoi')) {
      people = tripData['so_nguoi'] is int 
          ? tripData['so_nguoi'] 
          : int.tryParse(tripData['so_nguoi'].toString()) ?? 1;
    }
    
    // Tạo đối tượng trip đã làm giàu
    Map<String, dynamic> enrichedTrip = {
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
      'userTripDocId': trip['userTripDocId'] ?? '',
    };
    
    // Thông tin trạng thái chuyến đi
    if (tripStatus == 1) { // Đã hoàn thành
      enrichedTrip['completion_date'] = dateText;
      
      // Thêm thông tin đánh giá nếu có
      await _addReviewInfo(enrichedTrip);
    } else if (tripStatus == 2) { // Đã hủy
      enrichedTrip['cancelled_date'] = dateText;
    } else if (tripStatus == 0) { // Đang áp dụng
      enrichedTrip['start_date'] = dateText;
    }
    
    return enrichedTrip;
  }
  
  // Phương thức đếm số hoạt động và bữa ăn từ timelines
  Future<Map<String, int>> _countActivitiesAndMeals({
    required String userId,
    required String seTripId,
    required String locationId
  }) async {
    int activities = 0;
    int meals = 0;
    
    try {
      // Đọc timelines từ selected_trip
      final timelinesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('selected_trips')
          .doc(seTripId)
          .collection('timelines')
          .get();
      
      // Không có timelines, không đếm được
      if (timelinesSnapshot.docs.isEmpty) {
        return {'activities': 0, 'meals': 0};
      }
      
      // Đếm tổng số hoạt động và số bữa ăn
      for (var timelineDoc in timelinesSnapshot.docs) {
        final scheduleSnapshot = await timelineDoc.reference
            .collection('schedule')
            .get();
        
        // Tổng số hoạt động là tổng số schedule
        activities += scheduleSnapshot.docs.length;
        
        // Đếm số bữa ăn bằng cách kiểm tra loại hoạt động
        for (var scheduleDoc in scheduleSnapshot.docs) {
          final actId = scheduleDoc.data()['act_id'] as String?;
          if (actId == null || actId.isEmpty) continue;
          
          final activityDoc = await _firestore
              .collection('dia_diem')
              .doc(locationId)
              .collection('activities')
              .doc(actId)
              .get();
              
          if (activityDoc.exists && activityDoc.data()?['categories'] == 'eat') {
            meals++;
          }
        }
      }
      
      return {'activities': activities, 'meals': meals};
    } catch (e) {
      print('Lỗi khi đếm hoạt động và bữa ăn: $e');
      return {'activities': 0, 'meals': 0};
    }
  }
  
  // Thêm thông tin đánh giá vào trip nếu có
  Future<void> _addReviewInfo(Map<String, dynamic> trip) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (currentUserId.isEmpty) return;
      
      final tripId = trip['trip_id'] as String? ?? '';
      if (tripId.isEmpty) return;
      
      // Tìm đánh giá của người dùng hiện tại cho trip này
      final reviewQuery = await _firestore
          .collection('reviews')
          .where('user_id', isEqualTo: currentUserId)
          .where('trip_id', isEqualTo: tripId)
          .limit(1)
          .get();
          
      if (reviewQuery.docs.isEmpty) {
        // Không có đánh giá
        trip['rating'] = 0;
        trip['review_id'] = '';
        trip['comment'] = '';
        return;
      }
      
      // Có đánh giá, thêm thông tin
      final reviewDoc = reviewQuery.docs.first;
      final reviewData = reviewDoc.data();
      
      // Xử lý rating an toàn
      int rating = 0;
      final votes = reviewData['votes'];
      
      if (votes != null) {
        if (votes is int) {
          rating = votes;
        } else if (votes is String) {
          rating = int.tryParse(votes) ?? 0;
        } else {
          rating = int.tryParse(votes.toString()) ?? 0;
        }
      }
      
      trip['rating'] = rating;
      trip['review_id'] = reviewDoc.id;
      trip['comment'] = reviewData['comment'] ?? '';
    } catch (e) {
      print('Lỗi khi thêm thông tin đánh giá: $e');
    }
  }
  
  // Cập nhật số lượng hoạt động và bữa ăn
  Future<void> updateActivityAndMealCounts(String seTripId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null || seTripId.isEmpty) return;
      
      final seTripRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('selected_trips')
          .doc(seTripId);
      
      final seTripDoc = await seTripRef.get();
      if (!seTripDoc.exists) return;
      
      final locationId = seTripDoc.data()?['location_id'] as String? ?? '';
      if (locationId.isEmpty) return;
      
      final counts = await _countActivitiesAndMeals(
        userId: currentUserId,
        seTripId: seTripId,
        locationId: locationId
      );
      
      await seTripRef.update({
        'so_act': counts['activities'],
        'so_eat': counts['meals'],
        'updated_at': FieldValue.serverTimestamp()
      });
      
      print('Đã cập nhật số lượng hoạt động (${counts['activities']}) và bữa ăn (${counts['meals']}) cho selected_trip $seTripId');
    } catch (e) {
      print('Lỗi khi cập nhật số lượng hoạt động và bữa ăn: $e');
    }
  }
  
  // Lấy danh sách đánh giá của người dùng
  Future<List<Map<String, dynamic>>> getUserReviews() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (currentUserId.isEmpty) return [];

      // Lấy tất cả đánh giá của người dùng
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('user_id', isEqualTo: currentUserId)
          .get();
          
      final reviews = reviewsSnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
      
      // Làm giàu thông tin cho mỗi đánh giá
      List<Map<String, dynamic>> enrichedReviews = [];
      
      for (var review in reviews) {
        final tripId = review['trip_id'] as String?;
        if (tripId == null || tripId.isEmpty) continue;
        
        // Thêm review vào danh sách mà không cần làm giàu thêm
        enrichedReviews.add(review);
      }
      
      return enrichedReviews;
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

      // Lấy tất cả chuyến đi đã hoàn thành
      final completedTrips = await getUserTrips(tripStatus: 1);
      
      // Lấy tất cả đánh giá hiện tại
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('user_id', isEqualTo: currentUserId)
          .get();
          
      // Tạo danh sách các tripId đã đánh giá
      final reviewedTripIds = reviewsSnapshot.docs
          .map((doc) => doc.data()['trip_id'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
          
      // Lọc ra các chuyến đi chưa được đánh giá
      final pendingReviews = completedTrips
          .where((trip) => !reviewedTripIds.contains(trip['trip_id']))
          .toList();
          
      return pendingReviews;
    } catch (e) {
      print('Lỗi khi lấy danh sách chuyến đi cần đánh giá: $e');
      return [];
    }
  }
  
  // Lấy danh sách đánh giá của người dùng khác cho một trip cụ thể
  Future<List<Map<String, dynamic>>> getOtherUserReviews(String tripId) async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      
      // Lấy tất cả đánh giá của trip
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('trip_id', isEqualTo: tripId)
          .get();
          
      if (reviewsSnapshot.docs.isEmpty) {
        return [];
      }
      
      // Lọc và chuyển đổi dữ liệu
      final otherReviews = <Map<String, dynamic>>[];
      
      for (var doc in reviewsSnapshot.docs) {
        final data = doc.data();
        final userId = data['user_id'] as String? ?? '';
        
        if (userId != currentUserId) { // Chỉ lấy đánh giá của người dùng khác
          // Lấy thông tin người dùng nếu có
          String userName = 'Người dùng khác';
          try {
            final userDoc = await _firestore.collection('users').doc(userId).get();
            if (userDoc.exists) {
              final userData = userDoc.data();
              userName = userData?['fullname'] ?? userData?['email'] ?? userData?['displayName'] ?? 'Người dùng khác';
            }
          } catch (e) {
            print('Lỗi khi lấy thông tin người dùng: $e');
          }
          
          // Chuyển đổi timestamp thành chuỗi ngày
          String reviewDate = '';
          if (data.containsKey('created_at') && data['created_at'] is Timestamp) {
            final timestamp = data['created_at'] as Timestamp;
            reviewDate = DateFormat('dd/MM/yyyy').format(timestamp.toDate());
          }
          
          // Thêm vào danh sách
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
  
  // Lấy điểm đánh giá trung bình của một trip - Cải tiến sử dụng cache
  Future<double> getTripAverageRating(String tripId) async {
    if (_ratingsCache.containsKey(tripId)) {
      return _ratingsCache[tripId]!;
    }
    
    try {
      // Lấy tất cả đánh giá của trip
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('trip_id', isEqualTo: tripId)
          .get();
          
      if (reviewsSnapshot.docs.isEmpty) {
        _ratingsCache[tripId] = 0.0;
        return 0.0;
      }
      
      // Tính tổng số đánh giá
      int totalReviews = reviewsSnapshot.docs.length;
      
      // Tính tổng điểm đánh giá
      double totalRating = 0.0;
      for (var doc in reviewsSnapshot.docs) {
        final data = doc.data();
        final votes = data['votes'];
        
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
          
          totalRating += rating;
        }
      }
      
      // Tính trung bình
      double averageRating = totalReviews > 0 ? totalRating / totalReviews : 0.0;
      
      print('Đánh giá trung bình cho trip $tripId: $averageRating (từ $totalReviews đánh giá)');
      _ratingsCache[tripId] = averageRating;
      return averageRating;
    } catch (e) {
      print('Lỗi khi tính điểm đánh giá trung bình: $e');
      _ratingsCache[tripId] = 0.0;
      return 0.0;
    }
  }
}