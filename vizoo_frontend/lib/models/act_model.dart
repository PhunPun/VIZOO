class ActModel {
  final String actName;
  final String actAddress;
  final int actPrice;
  final String actCategories;

  ActModel({
    required this.actName,
    required this.actAddress,
    required this.actPrice,
    required this.actCategories,
  });

  static List<ActModel> getActModel() {
    return [
      // Ăn
      ActModel(
        actName: 'Ăn bánh canh ghẹ',
        actAddress: '123 Thùy Dương, Vũng Tàu',
        actPrice: 60000,
        actCategories: 'Ăn',
      ),
      ActModel(
        actName: 'Bún riêu cua Gánh',
        actAddress: '45 Trần Hưng Đạo, Vũng Tàu',
        actPrice: 45000,
        actCategories: 'Ăn',
      ),
      ActModel(
        actName: 'Hải sản Gành Hào',
        actAddress: '03 Trần Phú, Vũng Tàu',
        actPrice: 250000,
        actCategories: 'Ăn',
      ),
      ActModel(
        actName: 'Bánh khọt Cô Ba',
        actAddress: '01 Hoàng Hoa Thám, Vũng Tàu',
        actPrice: 50000,
        actCategories: 'Ăn',
      ),
      ActModel(
        actName: 'Bánh mì chảo xèo xèo',
        actAddress: '102 Nguyễn Văn Trỗi, Vũng Tàu',
        actPrice: 40000,
        actCategories: 'Ăn',
      ),
      ActModel(
        actName: 'Phở Thìn Hà Nội',
        actAddress: '88 Lê Lai, Vũng Tàu',
        actPrice: 60000,
        actCategories: 'Ăn',
      ),

      // Uống
      ActModel(
        actName: 'Coffee The Hill',
        actAddress: '56 Hải Đăng, Vũng Tàu',
        actPrice: 30000,
        actCategories: 'Uống',
      ),
      ActModel(
        actName: 'Highlands Coffee',
        actAddress: 'Lotte Mart, Vũng Tàu',
        actPrice: 45000,
        actCategories: 'Uống',
      ),
      ActModel(
        actName: 'Sailing Club Café',
        actAddress: '1 Trần Phú, Vũng Tàu',
        actPrice: 65000,
        actCategories: 'Uống',
      ),
      ActModel(
        actName: 'Cafe Bohemiens',
        actAddress: '155 Ba Cu, Vũng Tàu',
        actPrice: 35000,
        actCategories: 'Uống',
      ),
      ActModel(
        actName: 'Đen Đá Coffee',
        actAddress: '92 Nguyễn Thái Học, Vũng Tàu',
        actPrice: 40000,
        actCategories: 'Uống',
      ),

      // Chơi
      ActModel(
        actName: 'Tắm biển',
        actAddress: 'Công viên cột cờ, Vũng Tàu',
        actPrice: 0,
        actCategories: 'Chơi',
      ),
      ActModel(
        actName: 'Tham quan Hải đăng',
        actAddress: 'Núi Nhỏ, Vũng Tàu',
        actPrice: 10000,
        actCategories: 'Chơi',
      ),
      ActModel(
        actName: 'Lướt ván đứng',
        actAddress: 'Bãi Sau, Vũng Tàu',
        actPrice: 200000,
        actCategories: 'Chơi',
      ),
      ActModel(
        actName: 'Đi xe jeep ngắm biển',
        actAddress: 'Bãi Trước, Vũng Tàu',
        actPrice: 150000,
        actCategories: 'Chơi',
      ),
      ActModel(
        actName: 'Trượt zipline',
        actAddress: 'KDL Hồ Mây, Vũng Tàu',
        actPrice: 120000,
        actCategories: 'Chơi',
      ),

      // Nơi ở
      ActModel(
        actName: 'Khách sạn ABC',
        actAddress: 'Trần Phú, Vũng Tàu',
        actPrice: 1500000,
        actCategories: 'Nơi ở',
      ),
      ActModel(
        actName: 'Homestay Gió Biển',
        actAddress: 'Hồ Quý Ly, Vũng Tàu',
        actPrice: 600000,
        actCategories: 'Nơi ở',
      ),
      ActModel(
        actName: 'Resort Pullman',
        actAddress: '162 Trần Phú, Vũng Tàu',
        actPrice: 3200000,
        actCategories: 'Nơi ở',
      ),
      ActModel(
        actName: 'Hotel Imperial',
        actAddress: 'Bãi Sau, Vũng Tàu',
        actPrice: 2800000,
        actCategories: 'Nơi ở',
      ),
      ActModel(
        actName: 'Khách sạn 1993',
        actAddress: 'Phan Chu Trinh, Vũng Tàu',
        actPrice: 750000,
        actCategories: 'Nơi ở',
      ),
    ];
  }
}
