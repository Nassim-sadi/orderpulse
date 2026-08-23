import 'package:firebase_auth/firebase_auth.dart';

import '../entities/driver_profile.dart';

abstract interface class AuthRepository {
  Stream<User?> get authStateChanges;

  User? get currentUser;

  Future<DriverProfile?> loadProfile(String uid);

  Future<void> signInWithEmail(String email, String password);

  Future<void> registerDriver({
    required String name,
    required String phone,
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<void> updateProfile({
    required String uid,
    required String name,
    required String phone,
  });

  Future<void> signOut();
}
