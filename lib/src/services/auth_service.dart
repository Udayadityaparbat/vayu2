// lib/src/services/auth_service.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Google Sign-In (works on Web + Android + iOS)
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential? userCred;

      if (kIsWeb) {
        // --- Web Flow: Popup sign-in ---
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.setCustomParameters({'prompt': 'select_account'});
        userCred = await _auth.signInWithPopup(provider);
      } else {
        // --- Mobile Flow: GoogleSignIn package ---
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          return null; // user cancelled
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCred = await _auth.signInWithCredential(credential);
      }

      // After successful sign in, ensure a Firestore user doc exists.
      try {
        await ensureUserDoc(userCred?.user);
      } catch (e) {
        // Don't block sign-in on Firestore errors; log for debugging.
        // ignore: avoid_print
        print('ensureUserDoc error: $e');
      }

      return userCred;
    } catch (e) {
      // ignore: avoid_print
      print("Google Sign-In error: $e");
      rethrow;
    }
  }

  /// Create a minimal Firestore document for the user if one doesn't exist.
  /// Safe to call multiple times.
  static Future<void> ensureUserDoc(User? user) async {
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);

    try {
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        final now = FieldValue.serverTimestamp();
        await docRef.set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photoURL': user.photoURL ?? '',
          'profileCompleted': false,
          'createdAt': now,
          'lastSignIn': now,
        }, SetOptions(merge: true));
      } else {
        // update last sign-in timestamp (non-destructive)
        await docRef.set({'lastSignIn': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      }
    } catch (e) {
      // bubble up to caller if desired, or just log
      // ignore: avoid_print
      print('Error ensuring user doc: $e');
      rethrow;
    }
  }

  /// Optional sign-out
  static Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
    }
    return _auth.signOut();
  }
}
