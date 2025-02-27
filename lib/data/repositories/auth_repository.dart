import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:task_management/common/index.dart';
import '../models/index.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  // Get the current Firebase user (synchronous)
  UserModel? getFirebaseCurrentUser() {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      debugPrint("📌 AuthRepository: No current Firebase user");
      return null;
    }

    debugPrint("📌 AuthRepository: Current Firebase user: ${user.uid}");
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  Future<UserModel?> getCurrentUser() async {
    debugPrint("📌 AuthRepository: getCurrentUser called");

    // First try to get from Firebase Auth
    final User? user = _firebaseAuth.currentUser;
    if (user != null) {
      debugPrint("📌 AuthRepository: Found user in Firebase: ${user.uid}");
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );

      // Save to shared preferences
      await saveUserToPrefs(userModel);
      return userModel;
    }

    // If not in Firebase, try to retrieve from SharedPreferences
    debugPrint("📌 AuthRepository: No Firebase user, checking SharedPreferences");
    return await getUserFromPrefs();
  }

  Future<UserModel?> getUserFromPrefs() async {
    try {
      final userJson = await UserPreferences.getStringValue('current_user');
      debugPrint("📌 AuthRepository: User JSON from prefs: $userJson");

      if (userJson != null && userJson.isNotEmpty) {
        try {
          final Map<String, dynamic> userData = json.decode(userJson);
          final user = UserModel(
            id: userData['id'],
            email: userData['email'],
            displayName: userData['displayName'],
            photoUrl: userData['photoUrl'],
          );
          debugPrint("📌 AuthRepository: Successfully loaded user from prefs: ${user.id}");
          return user;
        } catch (e) {
          debugPrint('❌ AuthRepository: Error decoding user from prefs: $e');
          return null;
        }
      }
    } catch (e) {
      debugPrint('❌ AuthRepository: Error getting user from prefs: $e');
    }
    debugPrint("📌 AuthRepository: No user found in prefs");
    return null;
  }

  Future<void> saveUserToPrefs(UserModel user) async {
    try {
      final userData = {
        'id': user.id,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoUrl,
      };
      final userJson = json.encode(userData);
      debugPrint("📌 AuthRepository: Saving user to prefs: $userJson");

      await UserPreferences.setStringValue('current_user', userJson);
      await UserPreferences.setBoolValue('is_authenticated', true);

      // Verify it was saved correctly
      final savedJson = await UserPreferences.getStringValue('current_user');
      final isAuth = await UserPreferences.getBoolValue('is_authenticated');
      debugPrint("📌 AuthRepository: Verified user saved to prefs: $savedJson, isAuth: $isAuth");
    } catch (e) {
      debugPrint('❌ AuthRepository: Error saving user to prefs: $e');
    }
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
  }) async {
    debugPrint("📌 AuthRepository: signUp called with email: $email");
    try {
      final UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? user = credential.user;
      if (user == null) {
        throw Exception('User creation failed');
      }

      debugPrint("📌 AuthRepository: User created successfully: ${user.uid}");
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );

      // Save to shared preferences
      await saveUserToPrefs(userModel);

      return userModel;
    } catch (e) {
      debugPrint('❌ AuthRepository: Sign up failed: $e');
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    debugPrint("📌 AuthRepository: signIn called with email: $email");
    try {
      final UserCredential credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = credential.user;
      if (user == null) {
        throw Exception('Sign in failed');
      }

      debugPrint("📌 AuthRepository: User signed in successfully: ${user.uid}");
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );

      // Save to shared preferences
      await saveUserToPrefs(userModel);

      return userModel;
    } catch (e) {
      debugPrint('❌ AuthRepository: Sign in failed: $e');
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  Future<UserModel> signInWithGoogle() async {
    debugPrint("📌 AuthRepository: signInWithGoogle called");
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('❌ AuthRepository: Google sign in aborted by user');
        throw Exception('Google sign in aborted');
      }

      debugPrint("📌 AuthRepository: Google user signed in: ${googleUser.email}");
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint("📌 AuthRepository: Getting Firebase credentials");
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        debugPrint('❌ AuthRepository: Firebase user is null after Google sign in');
        throw Exception('Google sign in failed');
      }

      debugPrint("📌 AuthRepository: Firebase user created from Google: ${user.uid}");
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );

      // Save to shared preferences
      await saveUserToPrefs(userModel);

      return userModel;
    } catch (e) {
      debugPrint('❌ AuthRepository: Google sign in failed: $e');
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    debugPrint("📌 AuthRepository: signOut called");
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();

      // Clear preferences
      await UserPreferences.removeValue('current_user');
      await UserPreferences.setBoolValue('is_authenticated', false);

      debugPrint("📌 AuthRepository: User signed out successfully and prefs cleared");
    } catch (e) {
      debugPrint('❌ AuthRepository: Error signing out: $e');
      // Still attempt to clear preferences
      await UserPreferences.removeValue('current_user');
      await UserPreferences.setBoolValue('is_authenticated', false);
    }
  }

  Stream<bool> get isSignedIn {
    return _firebaseAuth.authStateChanges().map((User? user) {
      final bool isSignedIn = user != null;
      debugPrint("📌 AuthRepository: Firebase auth state changed: isSignedIn = $isSignedIn");
      return isSignedIn;
    });
  }

  Future<bool> isAuthenticatedFromPrefs() async {
    try {
      final isAuth = await UserPreferences.getBoolValue('is_authenticated') ?? false;
      debugPrint("📌 AuthRepository: isAuthenticatedFromPrefs = $isAuth");
      return isAuth;
    } catch (e) {
      debugPrint('❌ AuthRepository: Error checking auth from prefs: $e');
      return false;
    }
  }
}