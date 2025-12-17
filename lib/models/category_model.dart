class CategoryModel {
  String id;
  String name;
  String photo;

  CategoryModel({
    required this.id,
    required this.name,
    required this.photo,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'photo': photo,

    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      photo: map['photo'] ?? '',
    );
  }
}
