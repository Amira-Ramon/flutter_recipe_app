import 'generic_service.dart';
import '../models/user_model.dart';
import '../models/recipe_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class UserService extends FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String collection = "users";

  // CREATE
  Future<String> addUser(UserModel user) {
    return create(collection, user.toMap());
  }

  // READ
  Future<UserModel?> getUserById(String id) async {
    final doc = await readById(collection, id);
    if (doc==null ||!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, id);
  }  
  Future<UserModel?> getUserByName(String name) async {
    final doc = await readByName(collection, name);
    if (doc == null || !doc.exists) return null;

    return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }


  // UPDATE
  Future<void> updateUser(String id, UserModel user) {
    return update(collection, id, user.toMap());
  }

  // DELETE
  Future<void> deleteUser(String id) {
    return delete(collection, id);
  }

  // LIST
  Stream<List<UserModel>> getAllUsers() {
    return list(collection).map((QuerySnapshot snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }


 Future<void> toggleFavorite(String userId, String recipeId) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  final recipeRef = FirebaseFirestore.instance.collection('recipes').doc(recipeId);

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final userSnap = await transaction.get(userRef);
    final recipeSnap = await transaction.get(recipeRef);

    if (!userSnap.exists || !recipeSnap.exists) return;

    List favorites = List.from(userSnap.data()?['favorites'] ?? []);
    int favCount = recipeSnap.data()?['favorites_count'] ?? 0;

    if (favorites.contains(recipeId)) {
      favorites.remove(recipeId);
      favCount = (favCount > 0) ? favCount - 1 : 0;
    } else {
      favorites.add(recipeId);
      favCount++;
    }

    transaction.update(userRef, {"favorites": favorites});
    transaction.update(recipeRef, {"favorites_count": favCount});
  });
}



Stream<List<RecipeModel>> getUserFavoriteRecipes(String userId) {
  final userRef = FirebaseFirestore.instance.collection("users").doc(userId);

  return userRef.snapshots().asyncExpand((userSnap) {
    if (!userSnap.exists) return Stream.value([]);

    List<String> favs = List<String>.from(userSnap.data()?['favorites'] ?? []);
    if (favs.isEmpty) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection("recipes")
        .where(FieldPath.documentId, whereIn: favs)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RecipeModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  });
}



Stream<List<RecipeModel>> getRecipesByUser(String userId) {
  return FirebaseFirestore.instance
      .collection("recipes")
      .where('uploaded_by', isEqualTo: userId)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            return RecipeModel.fromMap(doc.data(), doc.id);
          }).toList());
}
Future<void> addRecipeToUser(String userId, String recipeId) async {
  final userRef = FirebaseFirestore.instance.collection("users").doc(userId);
  await userRef.update({
    'recipes': FieldValue.arrayUnion([recipeId])
  });
}

  Future<void> addFavorite(String userId, String recipeId) async {
    final userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);

      if (!snapshot.exists) return;

      List favorites = snapshot.get('favorites') ?? [];
      if (!favorites.contains(recipeId)) {
        favorites.add(recipeId);
        transaction.update(userRef, {'favorites': favorites});
      }
    });
  }

  Future<void> removeFavorite(String userId, String recipeId) async {
    final userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);

      if (!snapshot.exists) return;

      List favorites = snapshot.get('favorites') ?? [];
      if (favorites.contains(recipeId)) {
        favorites.remove(recipeId);
        transaction.update(userRef, {'favorites': favorites});
      }
    });
  }





}


