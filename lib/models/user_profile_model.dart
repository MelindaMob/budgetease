import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;

  UserProfileModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfileModel(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }
} 