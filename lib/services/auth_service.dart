// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// abstract class AuthServiceBase {
//   Future<UserCredential> register({
//     required String name,
//     required String email,
//     required String password,
//   });

//   Future<UserCredential> login({
//     required String email,
//     required String password,
//   });

//   Future<void> logout();

//   User? get currentUser;

//   Stream<User?> get authStateChanges;
// }

// class AuthService implements AuthServiceBase {
//   AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
//     : _auth = auth,
//       _firestore = firestore;

//   final FirebaseAuth? _auth;
//   final FirebaseFirestore? _firestore;

//   FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;

//   FirebaseFirestore get _firebaseFirestore =>
//       _firestore ?? FirebaseFirestore.instance;

//   @override
//   Future<UserCredential> register({
//     required String name,
//     required String email,
//     required String password,
//   }) async {
//     final credential = await _firebaseAuth.createUserWithEmailAndPassword(
//       email: email.trim(),
//       password: password,
//     );

//     final user = credential.user;

//     if (user != null) {
//       await user.updateDisplayName(name.trim());

//       await _firebaseFirestore.collection('users').doc(user.uid).set({
//         'name': name.trim(),
//         'email': email.trim(),
//         'photoUrl': null,
//         'role': 'user',
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//         'favoriteFandomIds': <String>[],
//       });
//     }

//     return credential;
//   }

//   @override
//   Future<UserCredential> login({
//     required String email,
//     required String password,
//   }) {
//     return _firebaseAuth.signInWithEmailAndPassword(
//       email: email.trim(),
//       password: password,
//     );
//   }

//   @override
//   Future<void> logout() async {
//     await _firebaseAuth.signOut();
//   }

//   @override
//   User? get currentUser => _firebaseAuth.currentUser;

//   @override
//   Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
// }





import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract class AuthServiceBase {
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  });

  Future<UserCredential> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  User? get currentUser;

  Stream<User?> get authStateChanges;

  // --------------------------------------------------------------------------
  // EMAIL VERIFICATION
  // --------------------------------------------------------------------------

  Future<void> resendVerificationEmail();

  Future<bool> checkEmailVerification();

  // --------------------------------------------------------------------------
  // GOOGLE AUTHENTICATION
  // --------------------------------------------------------------------------

  Future<UserCredential> signInWithGoogle();

  Future<void> completeGoogleRegistration({
    required String name,
    required String password,
  });
}

class AuthService implements AuthServiceBase {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth,
        _firestore = firestore;

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;

  FirebaseAuth get _firebaseAuth =>
      _auth ?? FirebaseAuth.instance;

  FirebaseFirestore get _firebaseFirestore =>
      _firestore ?? FirebaseFirestore.instance;

  // ==========================================================================
  // REGISTER WITH EMAIL + PASSWORD
  // ==========================================================================

  @override
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim();

    // ------------------------------------------------------------------------
    // CREATE FIREBASE AUTH ACCOUNT
    // ------------------------------------------------------------------------

    final credential =
        await _firebaseAuth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'registration-failed',
        message: 'Could not create the user account.',
      );
    }

    // ------------------------------------------------------------------------
    // SAVE DISPLAY NAME
    // ------------------------------------------------------------------------

    await user.updateDisplayName(cleanName);

    // ------------------------------------------------------------------------
    // SEND FIREBASE EMAIL VERIFICATION LINK
    // ------------------------------------------------------------------------

    await user.sendEmailVerification();

    // ------------------------------------------------------------------------
    // CREATE FIRESTORE PROFILE
    //
    // IMPORTANT:
    //
    // active = false
    // emailVerified = false
    //
    // The account becomes active only after the email is verified.
    // ------------------------------------------------------------------------

    await _firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .set({
      'name': cleanName,
      'email': cleanEmail,
      'photoUrl': null,

      // Existing role behavior preserved.
      'role': 'user',

      // Account is NOT active until email verification.
      'active': false,
      'emailVerified': false,

      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),

      'favoriteFandomIds': <String>[],
    });

    return credential;
  }

  // ==========================================================================
  // LOGIN WITH EMAIL + PASSWORD
  // ==========================================================================

  @override
  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ==========================================================================
  // RESEND EMAIL VERIFICATION
  // ==========================================================================

  @override
  Future<void> resendVerificationEmail() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user was found.',
      );
    }

    // If already verified, there is no reason to send another email.
    await user.reload();

    final refreshedUser = _firebaseAuth.currentUser;

    if (refreshedUser == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user was found.',
      );
    }

    if (refreshedUser.emailVerified) {
      return;
    }

    await refreshedUser.sendEmailVerification();
  }

  // ==========================================================================
  // CHECK EMAIL VERIFICATION
  // ==========================================================================

  @override
  Future<bool> checkEmailVerification() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      return false;
    }

    // Firebase caches the User object, so reload is required after the
    // verification link has been opened.
    await user.reload();

    final refreshedUser = _firebaseAuth.currentUser;

    if (refreshedUser == null) {
      return false;
    }

    final verified = refreshedUser.emailVerified;

    // ------------------------------------------------------------------------
    // ONLY AFTER VERIFICATION:
    //
    // active = true
    // emailVerified = true
    // ------------------------------------------------------------------------

    if (verified) {
      await _firebaseFirestore
          .collection('users')
          .doc(refreshedUser.uid)
          .set(
        {
          'emailVerified': true,
          'active': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    return verified;
  }

  // ==========================================================================
  // GOOGLE SIGN IN
  // ==========================================================================

  @override
  Future<UserCredential> signInWithGoogle() async {
    final provider = GoogleAuthProvider();

    provider.addScope('email');
    provider.addScope('profile');

    UserCredential credential;

    // ------------------------------------------------------------------------
    // WEB
    //
    // Firebase's popup flow is used for Flutter Web.
    // ------------------------------------------------------------------------

    if (kIsWeb) {
      credential = await _firebaseAuth.signInWithPopup(provider);
    }

    // ------------------------------------------------------------------------
    // ANDROID / IOS / NATIVE
    //
    // Firebase's native provider flow is used here.
    // ------------------------------------------------------------------------

    else {
      credential = await _firebaseAuth.signInWithProvider(provider);
    }

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'Google sign-in could not be completed.',
      );
    }

    // ------------------------------------------------------------------------
    // CHECK EXISTING FIRESTORE PROFILE
    // ------------------------------------------------------------------------

    final userRef =
        _firebaseFirestore.collection('users').doc(user.uid);

    final existingProfile = await userRef.get();

    if (!existingProfile.exists) {
      // ----------------------------------------------------------------------
      // NEW GOOGLE USER
      //
      // Google authentication itself has succeeded, but Fandom Verse
      // registration is not complete yet.
      //
      // The RegisterScreen will now ask for:
      // - Full Name
      // - Fandom Verse password
      // - Confirm password
      // ----------------------------------------------------------------------

      await userRef.set({
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL,

        'role': 'user',

        // Google has authenticated the email, but the Fandom Verse
        // registration setup is not completed yet.
        'active': false,
        'emailVerified': true,

        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),

        'favoriteFandomIds': <String>[],
      });
    }

    return credential;
  }

  // ==========================================================================
  // COMPLETE GOOGLE REGISTRATION
  // ==========================================================================

  @override
  Future<void> completeGoogleRegistration({
    required String name,
    required String password,
  }) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No Google account is currently signed in.',
      );
    }

    final cleanName = name.trim();

    // ------------------------------------------------------------------------
    // UPDATE FIREBASE DISPLAY NAME
    // ------------------------------------------------------------------------

    if (cleanName.isNotEmpty) {
      await user.updateDisplayName(cleanName);
    }

    // ------------------------------------------------------------------------
    // CREATE FANDOM VERSE PASSWORD
    //
    // This allows the Google-created account to also have an
    // email/password credential.
    // ------------------------------------------------------------------------

    try {
      await user.updatePassword(password);
    } on FirebaseAuthException catch (e) {
      // ----------------------------------------------------------------------
      // Normally the Google sign-in that just happened is recent enough for
      // updatePassword().
      //
      // If Firebase requires a recent login, reauthenticate with Google and
      // try once more.
      // ----------------------------------------------------------------------

      if (e.code != 'requires-recent-login') {
        rethrow;
      }

      final provider = GoogleAuthProvider();

      provider.addScope('email');
      provider.addScope('profile');

      if (kIsWeb) {
        await user.reauthenticateWithPopup(provider);
      } else {
        await user.reauthenticateWithProvider(provider);
      }

      await user.updatePassword(password);
    }

    // ------------------------------------------------------------------------
    // UPDATE FIRESTORE PROFILE
    //
    // Registration is now COMPLETE.
    // ------------------------------------------------------------------------

    await _firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .set(
      {
        'name': cleanName.isEmpty
            ? (user.displayName ?? '')
            : cleanName,

        'email': user.email ?? '',
        'photoUrl': user.photoURL,

        // Do NOT overwrite an existing role.
        'active': true,
        'emailVerified': true,

        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ==========================================================================
  // LOGOUT
  // ==========================================================================

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // ==========================================================================
  // CURRENT USER
  // ==========================================================================

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  // ==========================================================================
  // AUTH STATE
  // ==========================================================================

  @override
  Stream<User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();
}
