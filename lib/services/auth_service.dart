import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseAuth get instance => _auth;

  Stream<User?> get userChanges => _auth.authStateChanges();

  Future<User?> signUp(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = result.user;
    if (user != null) {
      await _firestore.collection('user_profiles').doc(user.uid).set({
        'id': user.uid,
        'email': email,
        'firstName': '',
        'lastName': ''
      });
    }
    return user;
  }
  
  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('user_profiles').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }
}