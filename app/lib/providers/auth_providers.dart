import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>((ref) {
  return firebase_auth.FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<firebase_auth.User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

// ✅ CORRECT: Uses asyncExpand to listen to Firestore in real-time
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges().asyncExpand((firebaseUser) {
    if (firebaseUser == null) {
      print('🔴 No auth user');
      return Stream.value(null);
    }
    print('🟢 Auth UID: ${firebaseUser.uid}');
    return FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            final user = AppUser.fromFirestore(doc);
            print('📄 User loaded: ${user.displayName}, shopId: ${user.shopId}');
            return user;
          } else {
            print('⚠️ User document not found for UID: ${firebaseUser.uid}');
            return null;
          }
        });
  });
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(firebaseAuthProvider));
});

class AuthService {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthService(this._auth);

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    UserRole role = UserRole.user,
  }) async {
    try {
      final authResult = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = authResult.user!.uid;
      await _firestore.collection('users').doc(uid).set({
        'email': email.trim(),
        'displayName': displayName.trim(),
        'role': role.name,
        'shopId': null,
        'riderId': null,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async => await _auth.signOut();

  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No user found with this email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'email-already-in-use': return 'Email already registered.';
      case 'invalid-email': return 'Invalid email address.';
      case 'weak-password': return 'Password too weak.';
      case 'network-request-failed': return 'Network error. Check connection.';
      default: return 'Auth error: ${e.message}';
    }
  }
}