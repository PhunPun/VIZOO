import 'package:cloud_firestore/cloud_firestore.dart';


class Trip {
  final String id;
  final String userId;
  final String locationId;
  final String name;
  final String anh;
  final int chiPhi;
  final int danhGia;
  final bool love;
  final DateTime ngayBatDau;
  final String noiO;
  final int soAct;
  final int soEat;
  final int soNgay;
  final int soNguoi;
  final bool status;
  final int? check;

  Trip({
    required this.id,
    required this.userId,
    required this.locationId,
    required this.name,
    required this.anh,
    required this.chiPhi,
    required this.danhGia,
    required this.love,
    required this.ngayBatDau,
    required this.noiO,
    required this.soAct,
    required this.soEat,
    required this.soNgay,
    required this.soNguoi,
    required this.status,
    required this.check,
  });


  factory Trip.fromJson(Map<String, dynamic> json, {
    required String id,
    required String locationId,
  }) {
    return Trip(
        id: id,
        locationId: locationId,
        name: json['name'] as String,
        anh: json['anh'] as String,
        chiPhi: json['chi_phi'] as int,
        danhGia: json['danh_gia'] as int,
        love: json['love'] as bool,
        ngayBatDau: (json['ngay_bat_dau'] as Timestamp).toDate(),
        noiO: json['noi_o'] as String,
        soAct: json['so_act'] as int,
        soEat: json['so_eat'] as int,
        soNgay: json['so_ngay'] as int,
        soNguoi: json['so_nguoi'] as int,
        status: json['status'] as bool? ?? false, userId: '',
        check: json.containsKey('check')
            ? (json['check'] as int?)
            : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'anh': anh,
      'chi_phi': chiPhi,
      'danh_gia': danhGia,
      'love': love,
      'ngay_bat_dau': Timestamp.fromDate(ngayBatDau),
      'noi_o': noiO,
      'so_act': soAct,
      'so_eat': soEat,
      'so_ngay': soNgay,
      'so_nguoi': soNguoi,
      'status': status,
      'check': check,
    };
  }
  factory Trip.fromJson1(Map<String, dynamic> json, {
    required String id,
    required String userId,
  }) {
    return Trip(
      id: id,
      userId: userId,
      name: json['name'] as String,
      anh: json['anh'] as String,
      chiPhi: json['chi_phi'] as int,
      danhGia: json['danh_gia'] as int,
      love: json['love'] as bool,
      ngayBatDau: (json['ngay_bat_dau'] as Timestamp).toDate(),
      noiO: json['noi_o'] as String,
      soAct: json['so_act'] as int,
      soEat: json['so_eat'] as int,
      soNgay: json['so_ngay'] as int,
      soNguoi: json['so_nguoi'] as int,
      status: (json['status'] ?? false) as bool, locationId: '',
      check: json['check'] as int?,
    );
  }

  get tripName => null;

  Map<String, dynamic> toJson1() {
    return {
      'name': name,
      'anh': anh,
      'chi_phi': chiPhi,
      'danh_gia': danhGia,
      'love': love,
      'ngay_bat_dau': Timestamp.fromDate(ngayBatDau),
      'noi_o': noiO,
      'so_act': soAct,
      'so_eat': soEat,
      'so_ngay': soNgay,
      'so_nguoi': soNguoi,
      'status': status,
    };
  }
  Trip copyWith({
    String? id,
    String? locationId,
    String? name,
    String? anh,
    int? chiPhi,
    int? danhGia,
    bool? love,
    DateTime? ngayBatDau,
    String? noiO,
    int? soAct,
    int? soEat,
    int? soNgay,
    int? soNguoi,
    bool? status,
    int? check,
  }) {
    return Trip(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      name: name ?? this.name,
      anh: anh ?? this.anh,
      chiPhi: chiPhi ?? this.chiPhi,
      danhGia: danhGia ?? this.danhGia,
      love: love ?? this.love,
      ngayBatDau: ngayBatDau ?? this.ngayBatDau,
      noiO: noiO ?? this.noiO,
      soAct: soAct ?? this.soAct,
      soEat: soEat ?? this.soEat,
      soNgay: soNgay ?? this.soNgay,
      soNguoi: soNguoi ?? this.soNguoi,
      status: status ?? this.status, userId: '',
      check: check ?? this.check,
    );
  }
}

