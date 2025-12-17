class Ingredient {
  final String item;
  final String quantity;

  Ingredient({required this.item, required this.quantity});

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      item: map['item'] ?? '',
      quantity: map['quantity'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item': item,
      'quantity': quantity,
    };
  }
}
class RecipeModel {
  String id;
  String name;
  String origin;
  String cooking_time;
  String photo;
  String short_description;
  List<String> steps;
  String uploaded_by;
  int favorites_count;
  List<Ingredient> ingredients; 
  String category_id;


  RecipeModel({
    required this.id,
    required this.name,
    required this.photo,
    required this.cooking_time,
    required this.short_description,
    required this.steps,
    required this.uploaded_by,
    required this.favorites_count,
    required this.origin,
    required this.ingredients,
    required this.category_id

  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'photo': photo,
      'cooking_time': cooking_time,
      'short_description': short_description,
      'steps': steps,
      'uploaded_by': uploaded_by,
      'favorites_count': favorites_count,
      'origin': origin,
      'ingredients': ingredients.map((e) => e.toMap()).toList(),
      'category_id': category_id

    };
  }

  factory RecipeModel.fromMap(Map<String, dynamic> map, String id) {
    String safeString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      return value.toString();
    }

    List<String> safeStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    List<Ingredient> parseIngredients(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) {
          if (e is Map<String, dynamic>) return Ingredient.fromMap(e);
          return Ingredient(item: '', quantity: '');
        }).toList();
      }
      return [];
    }

    return RecipeModel(
      id: id,
      name: safeString(map['name']),
      photo: safeString(map['photo']),
      cooking_time: safeString(map['cooking_time']),
      short_description: safeString(map['short_description']),
      uploaded_by: safeString(map['uploaded_by']),
      favorites_count: map['favorites_count'] is int
          ? map['favorites_count']
          : int.tryParse(map['favorites_count'].toString()) ?? 0,
      origin: safeString(map['origin']),
      ingredients: parseIngredients(map['ingredients']),  
      steps: safeStringList(map['steps']),
      category_id:  map['category_id'] ??'',

    );
  }
}
