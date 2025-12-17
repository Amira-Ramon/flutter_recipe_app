import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // CREATE
  Future<String> create(String collection, Map<String, dynamic> data) async {
    try {
      print("Creating entry in $collection...");
    
      DocumentReference ref = await _db.collection(collection).add(data);

      print("Data added successfully! Document ID: ${ref.id}");

      return ref.id;
    } 
    catch (e) {
      print("ERROR adding data to $collection: $e");
      rethrow; // rethrow the error so frontend can handle it if needed
    }
  }

  // READ
  Future<DocumentSnapshot?> readById(String collection, String id) async {
    try {
      print("Reading document with ID: $id");
      return await _db.collection(collection).doc(id).get();
    } catch (e) {
      print("ERROR reading by ID: $e");
      return null; // must return something
    }
  }

  Future<DocumentSnapshot?> readByName(String collection, String name) async {
    try {
      print("Reading document where name = $name");

      final query = await _db
          .collection(collection)
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        print("No document found with name $name");
        return null;
      }

      return query.docs.first;
    } catch (e) {
      print("ERROR reading by name: $e");
      return null;
    }
  }

  // UPDATE
  Future<bool> update(String collection, String id, Map<String, dynamic> data) async {
    try {
      print("Updating $collection/$id ...");
      await _db.collection(collection).doc(id).update(data);
      print("Update successful");
      return true;
    } catch (e) {
      print("UPDATE ERROR: $e");
      return false;
    }
  }


  // DELETE
  Future<bool> delete(String collection, String id) async {
    try {
      print("Deleting $collection/$id ...");
      await _db.collection(collection).doc(id).delete();
      print("Delete successful");
      return true;
    } catch (e) {
      print("DELETE ERROR: $e");
      return false;
    }
  }


  // LIST all documents
  Stream<QuerySnapshot> list(String collection) {
    print("Listening to collection: $collection");
    return _db
        .collection(collection)
        .snapshots()
        .handleError((e) => print("LIST STREAM ERROR: $e"));
  }

}
