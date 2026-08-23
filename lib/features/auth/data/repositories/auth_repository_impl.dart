import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/firestore_keys.dart';
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
    final doc = await _driverDoc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data() ?? {};
    return DriverProfile(
      uid: uid,
      name: data[DriverKeys.name] as String? ?? 'Driver',
      phone: data[DriverKeys.phone] as String? ?? '',
      email: data[DriverKeys.email] as String? ?? '',
      role: data[DriverKeys.role] as String? ?? 'DRIVER',
    );
  }

  @override
  Future<void> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> registerDriver({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = credential.user;
    if (user == null) throw StateError('Registration failed');
    await _driverDoc(user.uid).set({
      DriverKeys.name: name,
      DriverKeys.phone: phone,
      DriverKeys.email: email,
      DriverKeys.role: 'DRIVER',
      DriverKeys.createdAt: DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> signInWithGoogle() async {
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
    if (user == null) throw StateError('Google sign-in failed');
    final doc = await _driverDoc(user.uid).get();
    if (!doc.exists) {
      await _driverDoc(user.uid).set({
        DriverKeys.name: user.displayName ?? user.email ?? 'Driver',
        DriverKeys.phone: user.phoneNumber ?? '',
        DriverKeys.email: user.email ?? '',
        DriverKeys.role: 'DRIVER',
        DriverKeys.createdAt: DateTime.now().toIso8601String(),
      });
    }
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
}
