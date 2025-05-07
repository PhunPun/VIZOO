import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Lấy thông tin trip từ bảng selected_trips và dia_diem
  Future<List<Map<String, dynamic>>> getUserTrips({
    required int tripStatus, // 0: đang áp dụng, 1: hoàn thành, 2: đã hủy
  }) async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (currentUserId.isEmpty) return [];

      print('Đang lấy danh sách các chuyến đi với trạng thái: $tripStatus cho user: $currentUserId');
      
      // Lấy tất cả chuyến đi của người dùng với trạng thái tương ứng từ selected_trips
      final userTripsSnapshot = await _firestore
          .collection('selected_trips')
          .where('user_id', isEqualTo: currentUserId)
          .where('check', isEqualTo: tripStatus)
          .get();

      print('Tìm thấy ${userTripsSnapshot.docs.length} chuyến đi');

      if (userTripsSnapshot.docs.isEmpty) {
        return [];
      }

      // Lấy tất cả locations một lần để tối ưu hiệu suất
      final locationsSnapshot = await _firestore
          .collection('dia_diem')
          .get();
      
      // Tạo map của location data để tìm kiếm nhanh hơn
      Map<String, Map<String, dynamic>> locationsMap = {};
      for (var doc in locationsSnapshot.docs) {
        locationsMap[doc.id] = {...doc.data(), 'id': doc.id};
      }

      // Lấy reviews nếu đây là chuyến đi đã hoàn thành
      Map<String, Map<String, dynamic>> reviewsMap = {};
      if (tripStatus == 1) {
        final reviewsSnapshot = await _firestore
            .collection('reviews')
            .where('user_id', isEqualTo: currentUserId)
            .get();
            
        for (var doc in reviewsSnapshot.docs) {
          final data = doc.data();
          final tripId = data['trip_id'] as String? ?? '';
          if (tripId.isNotEmpty) {
            reviewsMap[tripId] = {...data, 'id': doc.id};
          }
        }
      }

      // Kết quả cuối cùng
      List<Map<String, dynamic>> trips = [];

      // Xử lý cho từng document trong selected_trips
      for (var userTripDoc in userTripsSnapshot.docs) {
        final userTripData = userTripDoc.data();
        final String tripId = userTripDoc.id; // ID của document là trip_id
        final String locationId = userTripData['location_id'] as String? ?? '';
        
        if (locationId.isEmpty) {
          print('LocationId trống cho trip: $tripId');
          continue; 
        }
        
        print('Xử lý chuyến đi: $tripId với location: $locationId');
        
        // Lấy thông tin location
        Map<String, dynamic>? locationData = locationsMap[locationId];
        if (locationData == null) {
          print('Không tìm thấy thông tin địa điểm với id: $locationId');
          continue;
        }
        
        // Lấy thông tin trip từ subcollection trips của địa điểm
        Map<String, dynamic> tripData = {};
        try {
          final tripDoc = await _firestore
              .collection('dia_diem')
              .doc(locationId)
              .collection('trips')
              .doc(tripId)
              .get();
              
          if (tripDoc.exists) {
            tripData = tripDoc.data() ?? {};
          } else {
            // Thử lấy từ timelines và schedule nếu không có trong trips
            print('Thử lấy thông tin từ timelines cho trip: $tripId');
            
            int activities = 0;
            int meals = 0;
            
            // Tìm kiếm trong timelines
            final timelinesSnapshot = await _firestore
                .collection('dia_diem')
                .doc(locationId)
                .collection('trips')
                .doc(tripId)
                .collection('timelines')
                .get();
                
            for (var timelineDoc in timelinesSnapshot.docs) {
              final scheduleSnapshot = await timelineDoc.reference
                  .collection('schedule')
                  .get();
                  
              activities += scheduleSnapshot.docs.length;
              
              // Đếm số bữa ăn
              for (var scheduleDoc in scheduleSnapshot.docs) {
                final actId = scheduleDoc.data()['act_id'] as String?;
                if (actId == null) continue;
                
                final actDoc = await _firestore
                    .collection('dia_diem')
                    .doc(locationId)
                    .collection('activities')
                    .doc(actId)
                    .get();
                    
                if (actDoc.exists && actDoc.data()?['categories'] == 'eat') {
                  meals++;
                }
              }
            }
            
            tripData = {
              'so_act': activities,
              'so_eat': meals,
              'so_nguoi': userTripData['people'] ?? 1,
              'noi_o': userTripData['accommodation'] ?? 'Không xác định',
              'chi_phi': userTripData['price'] ?? 0,
              'anh': userTripData['anh'] ?? locationData['hinh_anh1'] ?? '',
              'so_ngay': userTripData['so_ngay'] ?? locationData['so_ngay'] ?? 1,
              'name': locationData['ten'] ?? 'Không xác định',
            };
          }
        } catch (e) {
          print('Lỗi khi tìm trip $tripId trong location $locationId: $e');
        }
        
        // Format date - sử dụng last_updated trong selected_trips
        String dateText = 'Không xác định';
        if (userTripData.containsKey('last_updated') && userTripData['last_updated'] is Timestamp) {
          final timestamp = userTripData['last_updated'] as Timestamp;
          final date = timestamp.toDate();
          dateText = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
        }
        
        // Xử lý an toàn cho số ngày
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

        // Xử lý an toàn các thông tin khác
        final activities = tripData.containsKey('so_act') ? 
            (tripData['so_act'] is int ? tripData['so_act'] : int.tryParse(tripData['so_act']?.toString() ?? '0') ?? 0) : 0;
            
        final meals = tripData.containsKey('so_eat') ? 
            (tripData['so_eat'] is int ? tripData['so_eat'] : int.tryParse(tripData['so_eat']?.toString() ?? '0') ?? 0) : 0;
            
        final people = tripData.containsKey('so_nguoi') ? 
            (tripData['so_nguoi'] is int ? tripData['so_nguoi'] : int.tryParse(tripData['so_nguoi']?.toString() ?? '1') ?? 1) : 1;
            
        final price = tripData.containsKey('chi_phi') ? 
            (tripData['chi_phi'] is int ? tripData['chi_phi'] : int.tryParse(tripData['chi_phi']?.toString() ?? '0') ?? 0) : 0;
        
        // Lấy hình ảnh từ nhiều nguồn khác nhau
        String imageUrl = 'assets/images/vungtau.png'; // Mặc định
        if (tripData.containsKey('anh') && tripData['anh'] != null && tripData['anh'].toString().isNotEmpty) {
          imageUrl = tripData['anh'];
        } else if (userTripData.containsKey('anh') && userTripData['anh'] != null && userTripData['anh'].toString().isNotEmpty) {
          imageUrl = userTripData['anh'];
        } else if (locationData.containsKey('hinh_anh1') && locationData['hinh_anh1'] != null) {
          imageUrl = locationData['hinh_anh1'];
        }
        
        // Tạo đối tượng trip
        Map<String, dynamic> tripInfo = {
          'trip_id': tripId,
          'location_id': locationId,
          'location': locationData['ten'] ?? 'Không xác định',
          'duration': '$soDays ngày ${soDays > 1 ? (soDays - 1) : 0} đêm',
          'activities': activities,
          'meals': meals,
          'people': people,
          'accommodation': tripData['noi_o'] ?? userTripData['noi_o'] ?? 'Không xác định',
          'price': price,
          'imageUrl': imageUrl,
          'userTripDocId': userTripDoc.id,
        };
        
        // Thêm thông tin tùy theo loại chuyến đi
        if (tripStatus == 1) { // Đã hoàn thành
          tripInfo['completion_date'] = dateText;
          
          // Thêm thông tin đánh giá nếu có
          if (reviewsMap.containsKey(tripId)) {
            final reviewData = reviewsMap[tripId]!;
            int rating = 0;
            
            // Xử lý rating an toàn
            final votesData = reviewData['votes'];
            if (votesData != null) {
              if (votesData is int) {
                rating = votesData;
              } else if (votesData is String) {
                rating = int.tryParse(votesData) ?? 0;
              } else if (votesData is double) {
                rating = votesData.toInt();
              } else {
                rating = int.tryParse(votesData.toString()) ?? 0;
              }
            }
            
            tripInfo['rating'] = rating;
            tripInfo['review_id'] = reviewData['id'];
            tripInfo['comment'] = reviewData['comment'] ?? '';
          } else {
            tripInfo['rating'] = 0;
            tripInfo['review_id'] = '';
            tripInfo['comment'] = '';
          }
        } else if (tripStatus == 2) { // Đã hủy
          tripInfo['cancelled_date'] = dateText;
        }
        
        trips.add(tripInfo);
        print('Đã thêm chuyến đi: $tripId - ${locationData['ten']}');
      }

      print('Tổng số chuyến đi xử lý: ${trips.length}');
      return trips;
    } catch (e) {
      print('Lỗi khi lấy danh sách chuyến đi: $e');
      return [];
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
}