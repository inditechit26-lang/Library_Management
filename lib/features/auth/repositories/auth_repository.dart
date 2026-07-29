import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/error_handler.dart';

abstract class BaseAuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<AppUserModel?> getUserProfile(String uid);
  Future<AppUserModel> signInWithEmail(String email, String password);
  Future<AppUserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String libraryName,
    required String phone,
  });
  Future<AppUserModel?> signInWithGoogle();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<User?> reloadCurrentUser();
  Future<void> markEmailVerified(String uid);
  Future<void> signOut();
}

class AuthRepository implements BaseAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<AppUserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return AppUserModel.fromFirestore(doc);
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<AppUserModel> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Authentication failed. User is null.');
      }

      final profile = await getUserProfile(user.uid);
      if (profile == null) {
        // Fallback or self-healing: create user doc if missing
        final libraryId = 'lib_${user.uid.substring(0, 8)}';
        final newProfile = AppUserModel(
          uid: user.uid,
          email: user.email ?? email,
          displayName: user.displayName ?? 'Library Owner',
          libraryId: libraryId,
          role: 'owner',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set({
          ...newProfile.toFirestore(),
          'emailVerified': user.emailVerified,
          'verificationCompletedAt': user.emailVerified
              ? FieldValue.serverTimestamp()
              : null,
        });
        return newProfile;
      }

      return profile;
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<AppUserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String libraryName,
    required String phone,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('User creation failed.');
      }

      final libraryId = 'lib_${DateTime.now().millisecondsSinceEpoch}';

      final newProfile = AppUserModel(
        uid: user.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        libraryId: libraryId,
        role: 'owner',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create User doc & Default Library Config in a batch transaction
      final batch = _firestore.batch();
      batch.set(_firestore.collection('users').doc(user.uid), {
        ...newProfile.toFirestore(),
        'phone': phone.trim(),
        'emailVerified': false,
        'verificationCompletedAt': null,
      });
      batch.set(
        _firestore
            .collection('libraries')
            .doc(libraryId)
            .collection('info')
            .doc('general'),
        {
          'libraryId': libraryId,
          'name': libraryName.trim(),
          'ownerUid': user.uid,
          'phone': phone.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
      batch.set(
        _firestore
            .collection('libraries')
            .doc(libraryId)
            .collection('config')
            .doc('settings'),
        {
          'totalSeats': 0,
          'autoReceiptNumbering': true,
          'currency': 'INR',
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
      return newProfile;
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<AppUserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      var profile = await getUserProfile(user.uid);
      if (profile == null) {
        final libraryId = 'lib_${user.uid.substring(0, 8)}';
        profile = AppUserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Library Admin',
          photoUrl: user.photoURL,
          libraryId: libraryId,
          role: 'owner',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final batch = _firestore.batch();
        batch.set(_firestore.collection('users').doc(user.uid), {
          ...profile.toFirestore(),
          'emailVerified': user.emailVerified,
          'verificationCompletedAt': user.emailVerified
              ? FieldValue.serverTimestamp()
              : null,
        });
        batch.set(
          _firestore
              .collection('libraries')
              .doc(libraryId)
              .collection('info')
              .doc('general'),
          {
            'libraryId': libraryId,
            'name': '${user.displayName ?? "My"}\'s Study Library',
            'ownerUid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          },
        );
        await batch.commit();
      }

      return profile;
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw const AuthException('Your session has expired.');
      await user.sendEmailVerification();
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<User?> reloadCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      await user.reload();
      return _firebaseAuth.currentUser;
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> markEmailVerified(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'emailVerified': true,
        'verificationCompletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }
}
