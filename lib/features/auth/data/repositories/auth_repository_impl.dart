import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firestore_keys.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/driver_profile.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  bool _googleInitialized = false;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  DocumentReference<Map<String, dynamic>> _driverDoc(String uid) =>
      _firestore.collection(FirestoreCollections.drivers).doc(uid);

  @override
  Future<DriverProfile?> loadProfile(String uid) async {
    try {
      final doc = await _driverDoc(uid).get();
      if (!doc.exists) return null;
      final data = doc.data() ?? {};
      return DriverProfile(
        uid: uid,
        name: data[DriverKeys.name] as String? ?? 'Driver',
        phone: data[DriverKeys.phone] as String? ?? '',
        email: data[DriverKeys.email] as String? ?? '',
        role: data[DriverKeys.role] as String? ?? 'DRIVER',
        trustScore:
            (data[DriverKeys.trustScore] as num?)?.toInt() ??
                AppConstants.defaultTrustScore,
      );
    } on FirebaseException {
      return null;
    }
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuth(e);
    }
  }

  @override
  Future<void> registerDriver({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = credential.user;
      if (user == null) throw const AuthFailure(AuthFailureKind.unknown);
      await _driverDoc(user.uid).set(_driverDocData(
        name: name,
        phone: phone,
        email: email,
        role: 'DRIVER',
      ));
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuth(e);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn.instance;
      if (!_googleInitialized) {
        await googleSignIn.initialize();
        _googleInitialized = true;
      }
      final account = await googleSignIn.authenticate();
      final authentication = account.authentication;
      final credential =
          GoogleAuthProvider.credential(idToken: authentication.idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw const AuthFailure(AuthFailureKind.unknown);
      final doc = await _driverDoc(user.uid).get();
      if (!doc.exists) {
        await _driverDoc(user.uid).set(_driverDocData(
          name: user.displayName ?? user.email ?? 'Driver',
          phone: user.phoneNumber ?? '',
          email: user.email ?? '',
          role: 'DRIVER',
        ));
      }
    } on AuthFailure {
      rethrow;
    } on GoogleSignInException catch (e) {
      throw _mapGoogleSignIn(e);
    } on PlatformException catch (e) {
      throw _mapGooglePlatform(e);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw const AuthFailure(AuthFailureKind.network);
      }
      throw const AuthFailure(AuthFailureKind.googleUnavailable);
    }
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String phone,
  }) async {
    await _driverDoc(uid).update({
      DriverKeys.name: name,
      DriverKeys.phone: phone,
    });
  }

  @override
  Future<void> signOut() async {
    try {
      final googleSignIn = GoogleSignIn.instance;
      if (_googleInitialized) {
        await googleSignIn.signOut();
      }
    } catch (_) {}
    await _auth.signOut();
  }

  Map<String, dynamic> _driverDocData({
    required String name,
    required String phone,
    required String email,
    required String role,
  }) =>
      {
        DriverKeys.name: name,
        DriverKeys.phone: phone,
        DriverKeys.email: email,
        DriverKeys.role: role,
        DriverKeys.trustScore: AppConstants.defaultTrustScore,
        DriverKeys.createdAt: DateTime.now().toIso8601String(),
      };

  AuthFailure _mapFirebaseAuth(FirebaseAuthException e) => switch (e.code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' ||
        'user-disabled' =>
          const AuthFailure(AuthFailureKind.invalidCredentials),
        'email-already-in-use' =>
          const AuthFailure(AuthFailureKind.emailInUse),
        'weak-password' => const AuthFailure(AuthFailureKind.weakPassword),
        'invalid-email' => const AuthFailure(AuthFailureKind.invalidEmail),
        'network-request-failed' => const AuthFailure(AuthFailureKind.network),
        'too-many-requests' =>
          const AuthFailure(AuthFailureKind.tooManyRequests),
        _ => AuthFailure(AuthFailureKind.unknown, e.code),
      };

  AuthFailure _mapGoogleSignIn(GoogleSignInException e) => switch (e.code) {
        GoogleSignInExceptionCode.canceled ||
        GoogleSignInExceptionCode.interrupted =>
          const AuthFailure(AuthFailureKind.googleCancelled),
        GoogleSignInExceptionCode.clientConfigurationError ||
        GoogleSignInExceptionCode.providerConfigurationError =>
          const AuthFailure(AuthFailureKind.googleUnavailable,
              'client/provider configuration'),
        _ => _guessAccountIssue(e.description ?? ''),
      };

  AuthFailure _mapGooglePlatform(PlatformException e) {
    if (e.code == 'network_error') {
      return const AuthFailure(AuthFailureKind.network);
    }
    return _guessAccountIssue(e.message ?? e.code);
  }

  AuthFailure _guessAccountIssue(String description) {
    final lowered = description.toLowerCase();
    if (lowered.contains('12500') ||
        lowered.contains('10:') ||
        lowered.contains('no eligible accounts') ||
        lowered.contains('no accounts') ||
        lowered.contains('account')) {
      return AuthFailure(AuthFailureKind.googleNoAccount, description);
    }
    return AuthFailure(AuthFailureKind.googleUnavailable, description);
  }
}
