class DiaDiem {
  final String id;
  final String diachi;
  final String hinhAnh1;
  final String hinhAnh2;
  final String moTa;
  final String ten;

  DiaDiem({
    required this.id,
    required this.diachi,
    required this.hinhAnh1,
    required this.hinhAnh2,
    required this.moTa,
    required this.ten,
  });

  // Khởi tạo object từ Firestore document data
  factory DiaDiem.fromFirestore(Map<String, dynamic> data, String documentId) {
    return DiaDiem(
      id: documentId,
      diachi: data['dia_chi'] ?? '',
      hinhAnh1: data['hinh_anh1'] ?? '',
      hinhAnh2: data['hinh_anh2'] ?? '',
      moTa: data['mo_ta'] ?? '',
      ten: data['ten'] ?? '',
    );
  }
}
