import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class UserService {
  UserService._internal();
  static final UserService instance = UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createInitialUserProfile({
    required User user,
    required String name,
  }) async {
    final profile = UserProfile(
      uid: user.uid,
      name: name,
      email: user.email ?? '',
      interestPolitics: false,
      interestEconomy: false,
      interestSociety: false,
      interestLifeCulture: false,
      interestItScience: false,
      interestWorld: false,
      questionLevel: 2,
    );

    await _firestore.collection('users').doc(user.uid).set(profile.toMap());
  }

  Future<void> updateOnboardingSettings({
    required String uid,
    required bool interestPolitics,
    required bool interestEconomy,
    required bool interestSociety,
    required bool interestLifeCulture,
    required bool interestItScience,
    required bool interestWorld,
    required int questionLevel,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'interest_politics': interestPolitics,
      'interest_economy': interestEconomy,
      'interest_society': interestSociety,
      'interest_life_culture': interestLifeCulture,
      'interest_it_science': interestItScience,
      'interest_world': interestWorld,
      'question_level': questionLevel,
    });
  }
}
