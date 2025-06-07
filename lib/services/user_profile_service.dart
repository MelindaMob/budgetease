import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';

class UserProfileService {
  final CollectionReference _profileCollection =
      FirebaseFirestore.instance.collection('profiles');

  // Obtenir le profil utilisateur
  Stream<UserProfileModel?> getUserProfile(String userId) {
    return _profileCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfileModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // Mettre à jour le profil
  Future<void> updateProfile(String userId, UserProfileModel profile) async {
    try {
      await _profileCollection.doc(userId).set(profile.toMap());
    } catch (e) {
      print('Erreur lors de la mise à jour du profil: $e');
      throw e;
    }
  }
} 