import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String userCollection = 'users';

  // Create user in FirebaseAuth + Firestore
  Future<UserModel> registerWithEmailPassword({
    required String name,
    required String email,
    required String password,
    Uint8List? profileImageBytes,
  }) async {
    try {
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // final String uid = credential.user!.uid;
      final user = credential.user;
      if (user == null) {
        throw Exception('User is null - authentication failed');
      }

      final uid = user.uid;

      String? imageUrl;
      if (profileImageBytes != null) {
        imageUrl = await _uploadProfileImage(uid, profileImageBytes);
      }

      final userModel = UserModel(
        uid: uid,
        name: name,
        email: email,
        image: imageUrl ?? '',
        favorites: [],
        recipes: [],
      );

      // Enable network before writing
      await _ensureNetwork();

      // Write to Firestore with network priority
      try {
        await _fs.collection(userCollection).doc(uid).set(userModel.toMap());
      } catch (e) {
        print('Warning: Could not write user to Firestore: $e');
        // Continue anyway - user can sync later
      }

      // Update FirebaseAuth profile
      await credential.user!.updateDisplayName(name);
      if (imageUrl != null) await credential.user!.updatePhotoURL(imageUrl);

      return userModel;
    } catch (e) {
      print('Registration failed: $e');
      rethrow;
    }
  }

  // Login with email & password - WITH IMPROVED OFFLINE HANDLING
  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('1. Starting authentication...');

      // 1. Authenticate user
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      print('2. User authenticated: $uid');

      // 2. Try to enable network (but don't fail if it doesn't work)
      await _ensureNetwork();

      // 3. Try to get user data with intelligent fallback
      UserModel? userModel = await _getUserDataWithFallback(uid);

      // 4. If user document doesn't exist, create one
      if (userModel == null) {
        print('4. Creating new user document...');
        final u = credential.user!;
        final fallback = UserModel(
          uid: uid,
          name: u.displayName ?? nameFromEmail(email),
          email: u.email ?? email,
          image: u.photoURL ?? '',
          favorites: [],
          recipes: [],
        );

        // Try to save, but don't fail if offline
        try {
          await _fs.collection(userCollection).doc(uid).set(fallback.toMap());
          print('5. User document created successfully');
        } catch (e) {
          print('5. Could not save user to Firestore (offline): $e');
          // Continue with local user model
        }

        return fallback;
      }

      print('6. Returning existing user data');
      return userModel;
    } catch (e) {
      print('Login failed: $e');
      rethrow;
    }
  }

  // Helper method to get user data with network/cache fallback
  Future<UserModel?> _getUserDataWithFallback(String uid) async {
    print('3. Getting user data for: $uid');

    // Try to get from network first
    try {
      print('   Trying network fetch...');
      final userDoc = await _fs
          .collection(userCollection)
          .doc(uid)
          .get(const GetOptions(source: Source.server));

      if (userDoc.exists && userDoc.data() != null) {
        print('   User found via network');
        return UserModel.fromMap(userDoc.data()!, userDoc.id);
      }
    } catch (networkError) {
      print('   Network fetch failed: $networkError');

      // Fallback to cache
      try {
        print('   Trying cache fetch...');
        final cachedDoc = await _fs
            .collection(userCollection)
            .doc(uid)
            .get(const GetOptions(source: Source.cache));

        if (cachedDoc.exists && cachedDoc.data() != null) {
          print('   User found in cache');
          return UserModel.fromMap(cachedDoc.data()!, cachedDoc.id);
        }
      } catch (cacheError) {
        print('   Cache fetch failed: $cacheError');
      }
    }

    print('   User not found in network or cache');
    return null;
  }

  // Helper to ensure network is enabled
  Future<void> _ensureNetwork() async {
    try {
      await _fs.enableNetwork();
      print('Network enabled successfully');
    } catch (e) {
      print('Network enable may have failed (could already be enabled): $e');
      // Don't throw - continue anyway
    }
  }

  // Helper to extract name from email
  String nameFromEmail(String email) {
    final parts = email.split('@');
    return parts[0]
        .replaceAll('.', ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get a stream of current user's UserModel (for profile page)
  Stream<UserModel?> userModelStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream<UserModel?>.value(null);

    return _fs
        .collection(userCollection)
        .doc(user.uid)
        .snapshots()
        .handleError((error) {
          print('Error in user stream: $error');
          // Return null on error to prevent stream from closing
          return null;
        })
        .map((snap) {
          if (!snap.exists || snap.data() == null) return null;
          return UserModel.fromMap(snap.data()!, snap.id);
        });
  }

  // Read user once with fallback
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _fs
          .collection(userCollection)
          .doc(uid)
          .get(const GetOptions(source: Source.serverAndCache));

      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  // Update profile: name and/or image
  Future<UserModel> updateProfile({
    required String uid,
    String? name,
    Uint8List? profileImageBytes,
  }) async {
    final Map<String, dynamic> updateData = {};

    if (name != null) updateData['name'] = name;

    if (profileImageBytes != null) {
      final url = await _uploadProfileImage(uid, profileImageBytes);
      updateData['image'] = url;

      // Update Firebase auth profile too
      final user = _auth.currentUser;
      if (user != null && user.uid == uid) {
        await user.updatePhotoURL(url);
      }
    }

    if (updateData.isNotEmpty) {
      try {
        await _ensureNetwork();
        await _fs.collection(userCollection).doc(uid).update(updateData);
      } catch (e) {
        print('Warning: Could not update profile (offline): $e');
        throw Exception('Could not update profile. Check your connection.');
      }
    }

    if (name != null) {
      final user = _auth.currentUser;
      if (user != null && user.uid == uid) {
        await user.updateDisplayName(name);
      }
    }

    final updated = await getUserById(uid);
    return updated!;
  }

  // Helper: upload profile image to Storage and return URL
  Future<String> _uploadProfileImage(String uid, Uint8List bytes) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');
      final UploadTask task = ref.putData(bytes);
      final snapshot = await task;
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Upload failed: $e');
      throw Exception('Could not upload image. Check your connection.');
    }
  }

  // Delete user document
  Future<void> deleteUser({
    required String uid,
    bool deleteAuthUser = false,
  }) async {
    try {
      await _ensureNetwork();
      await _fs.collection(userCollection).doc(uid).delete();

      if (deleteAuthUser) {
        final user = _auth.currentUser;
        if (user != null && user.uid == uid) {
          await user.delete();
        } else {
          throw FirebaseAuthException(
            code: 'requires-recent-login-or-admin',
            message: 'Deleting another auth user requires admin privileges.',
          );
        }
      }
    } catch (e) {
      print('Delete user failed: $e');
      rethrow;
    }
  }

  // Utility: current FirebaseAuth user id
  String? get currentUid => _auth.currentUser?.uid;
}
