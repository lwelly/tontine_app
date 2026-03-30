import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Inscription
  Future<User?> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result.user != null && !result.user!.emailVerified) {
      await result.user!.sendEmailVerification();
    }

    AppUser user = AppUser(
      uid: result.user!.uid,
      name: name,
      phone: phone,
      email: email,
    );

    await _db.collection('users').doc(user.uid).set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    });

    // After sign-up, return the user to the login page.
    await _auth.signOut();
    return null;
  }

  // Connexion
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user;
    if (user == null) return null;

    await user.reload();
    final refreshed = _auth.currentUser;
    if (refreshed == null) return null;

    await _db.collection('users').doc(refreshed.uid).set({
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return refreshed;
  }

  // Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
  }

  // État utilisateur
  Stream<User?> get authState => _auth.authStateChanges();
}
