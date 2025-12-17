class UserModel {
  String uid;
  String name;
  String email;
  String image;
  List<String> favorites;
  List<String> recipes;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.image,
    required this.favorites,
    required this.recipes,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'image': image,
      'favorites': favorites,
      'recipes': recipes,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      image: map['image'] ?? '',
      favorites: List<String>.from(map['favorites'] ?? []),
      recipes: List<String>.from(map['recipes'] ?? []),
    );
  }


}
