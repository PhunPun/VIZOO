class LocationsModel {
  final String name;
  final String imageUrl;

  LocationsModel({
    required this.name,
    required this.imageUrl
  });

  static List<LocationsModel> getLocations(){
    return[
      LocationsModel(
        name: 'Vung Tau', 
        imageUrl: 'https://i.pinimg.com/736x/44/5e/30/445e306f9477c2ee8a123aa0d11ae8b3.jpg',
      ),
      LocationsModel(
        name: 'Da Nang', 
        imageUrl: 'https://i.pinimg.com/736x/26/63/6c/26636c160f844f0cad0c52582b862e37.jpg',
      ),
      LocationsModel(
        name: 'Phu Quoc', 
        imageUrl: 'https://i.pinimg.com/736x/0a/f9/02/0af9027dd1561f5e7a720df5b4c24861.jpg',
      ),
      LocationsModel(
        name: 'Da Lat', 
        imageUrl: 'https://i.pinimg.com/736x/0c/b3/d4/0cb3d4f146129509cd04e6dbd1f3b913.jpg',
      ),
      LocationsModel(
        name: 'Sai Gon', 
        imageUrl: 'https://i.pinimg.com/736x/16/57/c3/1657c333c9764d0cc99b91dcbb326c06.jpg',
      ),
    ];
  }
}