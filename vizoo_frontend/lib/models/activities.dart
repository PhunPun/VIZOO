class Activity {
  final String name; // Thay "ten" -> "name"
  final String address; // Thay "diaChi" -> "address"
  final int price; // Thay "gia" -> "price"
  final String categories;

  Activity({
    required this.name,
    required this.address,
    required this.price,
    required this.categories,
  });

  factory Activity.fromFirestore(Map<String, dynamic> data) {
    return Activity(
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      price: (data['price'] as num?)?.toInt() ?? 0,
      categories: data['categories'] as String? ?? '',
    );
  }
}