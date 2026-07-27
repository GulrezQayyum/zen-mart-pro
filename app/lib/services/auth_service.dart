import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Sign up with email and password
  Future<AppUser?> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      final appUser = AppUser(
        id: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        role: role,
        createdAt: DateTime.now(),
        status: 'active',
      );

      await _firestore.collection('users').doc(appUser.id).set(appUser.toJson());

      return appUser;
    } on FirebaseAuthException catch (e) {
      print('Sign up error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        return AppUser.fromJson(userDoc.data()!);
      }

      return null;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Reset password error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }

  // Get current user data
  Future<AppUser?> getCurrentUserData() async {
    try {
      if (currentUser == null) return null;

      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists) {
        return AppUser.fromJson(userDoc.data()!);
      }

      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      if (currentUser == null) throw Exception('No user logged in');

      if (displayName != null) {
        await currentUser!.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await currentUser!.updatePhotoURL(photoURL);
      }

      // Update Firestore
      await _firestore.collection('users').doc(currentUser!.uid).update({
        if (displayName != null) 'displayName': displayName,
        if (photoURL != null) 'photoURL': photoURL,
      });

      await currentUser!.reload();
    } catch (e) {
      print('Update profile error: $e');
      rethrow;
    }
  }

  // Get user role stream (real-time updates)
  Stream<UserRole?> getUserRoleStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final role = snapshot.data()?['role'] ?? 'user';
        return UserRoleExtension.fromString(role);
      }
      return null;
    });
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      if (currentUser == null) throw Exception('No user logged in');

      final uid = currentUser!.uid;

      // Delete from Firestore
      await _firestore.collection('users').doc(uid).delete();

      // Delete from Firebase Auth
      await currentUser!.delete();
    } catch (e) {
      print('Delete account error: $e');
      rethrow;
    }
  }

  // Check if user is admin
  Future<bool> isUserAdmin(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final role = userDoc.data()?['role'] ?? 'user';
        return role == 'admin';
      }
      return false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Check if user is vendor
  Future<bool> isUserVendor(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final role = userDoc.data()?['role'] ?? 'user';
        return role == 'vendor' || role == 'admin';
      }
      return false;
    } catch (e) {
      print('Error checking vendor status: $e');
      return false;
    }
  }
}