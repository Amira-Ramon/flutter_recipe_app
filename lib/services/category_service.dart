import 'generic_service.dart';
import '../models/category_model.dart';

class CategoryService extends FirebaseService {
  final String collection = "categories";

  // CREATE
  Future<String> addCategory(CategoryModel category) {
    return create(collection, category.toMap());
  }

  // READ
  Future<CategoryModel?> getCategoryById(String id) async {
    final doc = await readById(collection, id);
    if (doc==null ||!doc.exists) return null;
    return CategoryModel.fromMap(doc.data() as Map<String, dynamic>, id);
  }

  Future<CategoryModel?> getCategoryByName(String name) async {
  final doc = await readByName(collection, name);

  if (doc == null) return null;
  if (!doc.exists) return null;

  return CategoryModel.fromMap(
    doc.data() as Map<String, dynamic>,
    doc.id,
  );
}

  // UPDATE
  Future<void> updateCategory(String id, CategoryModel category) {
    return update(collection, id, category.toMap());
  }

  // DELETE
  Future<void> deleteCategory(String id) {
    return delete(collection, id);
  }

  Stream<List<CategoryModel>> getAllCategories() {
  return list(collection).map((snapshot) {
    final querySnapshot = snapshot;
    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final filteredData = {
        'name': data['name'],
        'photo': data['photo'],
      };
      return CategoryModel.fromMap(filteredData, doc.id);
    }).toList();
});
}}

