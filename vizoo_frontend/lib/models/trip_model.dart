class TripModel {
  final String address; // dia diem
  final String imageUrl;
  final String dayNum; // so ngay
  final int activitiesNum; // so hoat dong
  final int mealNum; // so bua an
  final int peopleNum; // so nguoi
  final String residence; // noi o
  final int cost; // chi phi
  final int rating; // danh gia

  TripModel({
    required this.address,
    required this.imageUrl,
    required this.dayNum,
    required this.activitiesNum,
    required this.mealNum,
    required this.peopleNum,
    required this.residence,
    required this.cost,
    required this.rating,
  });

  static List<TripModel> getTrips(){
    return[
      TripModel(
        address: 'Vũng Tàu',
        imageUrl: 'https://i.pinimg.com/736x/44/5e/30/445e306f9477c2ee8a123aa0d11ae8b3.jpg',
        dayNum: '3 ngày 2 đêm',
        activitiesNum: 15,
        mealNum: 9,
        peopleNum: 1,
        residence: 'Nhà nghỉ Phun',
        cost: 2500000,
        rating: 4,
      ),
      TripModel(
        address: 'Đà Lạt',
        imageUrl: 'https://i.pinimg.com/736x/0c/b3/d4/0cb3d4f146129509cd04e6dbd1f3b913.jpg',
        dayNum: '4 ngày 3 đêm',
        activitiesNum: 20,
        mealNum: 12,
        peopleNum: 2,
        residence: 'Khách sạn Mộng Mơ',
        cost: 3200000,
        rating: 5,
      ),
      TripModel(
        address: 'Phú Quốc',
        imageUrl: 'https://i.pinimg.com/474x/0a/f9/02/0af9027dd1561f5e7a720df5b4c24861.jpg',
        dayNum: '5 ngày 4 đêm',
        activitiesNum: 25,
        mealNum: 15,
        peopleNum: 4,
        residence: 'Resort Vinpearl',
        cost: 8500000,
        rating: 5,
      ),
      TripModel(
        address: 'Hà Giang',
        imageUrl: 'https://i.pinimg.com/474x/e1/24/b1/e124b1393750f24c6356e560e59ca83c.jpg',
        dayNum: '3 ngày 2 đêm',
        activitiesNum: 12,
        mealNum: 8,
        peopleNum: 3,
        residence: 'Homestay Thổ Cẩm',
        cost: 1800000,
        rating: 4,
      ),
      TripModel(
        address: 'Nha Trang',
        imageUrl: 'https://i.pinimg.com/736x/54/15/89/5415890289eb3accbfe0469620a0dacc.jpg',
        dayNum: '4 ngày 3 đêm',
        activitiesNum: 18,
        mealNum: 10,
        peopleNum: 2,
        residence: 'Khách sạn Queen',
        cost: 4000000,
        rating: 4,
      ),
    ];
  }
}