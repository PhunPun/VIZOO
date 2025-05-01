class Activity {
  final String id;         
  final String name;
  final String address;
  final int price;
  final String categories;

  Activity({
    required this.id,      
    required this.name,
    required this.address,
    required this.price,
    required this.categories,
  });

  factory Activity.fromFirestore(Map<String, dynamic> data, {required String id}) {
    return Activity(
      id: id, 
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      price: (data['price'] as num?)?.toInt() ?? 0,
      categories: data['categories'] as String? ?? '',
    );
  }
}
