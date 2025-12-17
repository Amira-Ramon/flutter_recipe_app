import 'generic_service.dart';
import '../models/recipe_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeService extends FirebaseService {
  final String collection = "recipes";

  // CREATE
  Future<String> addRecipe(RecipeModel recipe) {
    return create(collection, recipe.toMap());
  }

  // READ
  Future<RecipeModel?> getRecipeById(String id) async {
    final doc = await readById(collection, id);
    if (doc==null ||!doc.exists) return null;
    return RecipeModel.fromMap(doc.data() as Map<String, dynamic>, id);
  }

  Future<RecipeModel?> getRecipeByName(String name) async {
    final doc = await readByName(collection, name);
    if (doc == null || !doc.exists) return null;

    return RecipeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }


  // UPDATE
  Future<void> updateRecipe(String id, RecipeModel recipe) {
    return update(collection, id, recipe.toMap());
  }

  // DELETE
  Future<void> deleteRecipe(String id) {
    return delete(collection, id);
  }

  // LIST
  Stream<List<RecipeModel>> getAllRecipes() {
    return list(collection).map((QuerySnapshot snapshot) {
      return snapshot.docs.map((doc) {
        return RecipeModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  Stream<List<RecipeModel>> searchRecipes(String keyword) {
    return FirebaseFirestore.instance
        .collection(collection)
        .where('keywords', arrayContains: keyword.toLowerCase())
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RecipeModel.fromMap(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  Stream<List<RecipeModel>>? getRecipesByUser(String currentUserId) {return FirebaseFirestore.instance
      .collection(collection)
      .where('uploaded_by', isEqualTo: currentUserId)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return RecipeModel.fromMap(doc.data(), doc.id);
    }).toList();
  });}
  Future<void> updateFavoriteCount(String recipeId, int change) async {
  final docRef = FirebaseFirestore.instance.collection('recipes').doc(recipeId);
  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final snapshot = await transaction.get(docRef);
    if (!snapshot.exists) return;
    final currentCount = snapshot['favorites_count'] ?? 0;
    transaction.update(docRef, {'favorites_count': currentCount + change});
  });
}


}

