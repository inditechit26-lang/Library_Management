import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/exceptions/app_exception.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/firestore_paths.dart';
import '../../../core/utils/error_handler.dart';

abstract class BaseAuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Stream<String?> watchCurrentLibraryId();
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
  Future<void> createLibraryForUser({
    required String uid,
    required String libraryName,
    String? phone,
  });
  Future<void> switchCurrentLibrary(String uid, String libraryId);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<User?> reloadCurrentUser();
  Future<void> markEmailVerified(String uid);
  Future<void> signOut();
}

class AuthRepository implements BaseAuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Stream<String?> watchCurrentLibraryId() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _firestore
        .doc(FirestorePaths.user(uid))
        .snapshots()
        .map((snapshot) => snapshot.data()?['currentLibraryId'] as String?);
  }

  @override
  Future<AppUserModel?> getUserProfile(String uid) async {
    try {
      final snapshot = await _firestore.doc(FirestorePaths.user(uid)).get();
      if (!snapshot.exists) return null;
      final data = snapshot.data() ?? const <String, dynamic>{};
      final profile = Map<String, dynamic>.from(
        data['profile'] as Map? ?? const <String, dynamic>{},
      );
      return AppUserModel(
        uid: uid,
        email: profile['email'] as String? ?? '',
        displayName: profile['displayName'] as String? ?? '',
        photoUrl: profile['photoUrl'] as String?,
        libraryId: data['currentLibraryId'] as String? ?? '',
        role: profile['role'] as String? ?? 'owner',
        createdAt:
            (profile['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt:
            (profile['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (error, stackTrace) {
      throw ErrorHandler.handle(error, stackTrace);
    }
  }

  @override
  Future<AppUserModel> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const AuthException('Authentication failed.');
      var profile = await getUserProfile(user.uid);
      if (profile == null) {
        await _initializeUserAndLibrary(
          user: user,
          displayName: user.displayName ?? 'Library Owner',
          libraryName: 'My Study Library',
          phone: '',
        );
        profile = await getUserProfile(user.uid);
      }
      return profile!;
    } catch (error, stackTrace) {
      throw ErrorHandler.handle(error, stackTrace);
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
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const AuthException('User creation failed.');
      await user.updateDisplayName(displayName.trim());
      await _initializeUserAndLibrary(
        user: user,
        displayName: displayName.trim(),
        libraryName: libraryName.trim(),
        phone: phone.trim(),
      );
      return (await getUserProfile(user.uid))!;
    } catch (error, stackTrace) {
      throw ErrorHandler.handle(error, stackTrace);
    }
  }

  @override
  Future<AppUserModel?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final user = (await _auth.signInWithCredential(credential)).user;
      if (user == null) return null;
      var profile = await getUserProfile(user.uid);
      if (profile == null) {
        await _initializeUserAndLibrary(
          user: user,
          displayName: user.displayName ?? 'Library Owner',
          libraryName: '${user.displayName ?? 'My'}\'s Study Library',
          phone: '',
        );
        profile = await getUserProfile(user.uid);
      }
      return profile;
    } catch (error, stackTrace) {
      throw ErrorHandler.handle(error, stackTrace);
    }
  }

  @override
  Future<void> createLibraryForUser({
    required String uid,
    required String libraryName,
    String? phone,
  }) async {
    final libraryId = _newLibraryId();
    final user = await _firestore.doc(FirestorePaths.user(uid)).get();
    final profile = Map<String, dynamic>.from(
      user.data()?['profile'] as Map? ?? const <String, dynamic>{},
    );
    final batch = _firestore.batch();
    batch.set(
      _firestore.doc(FirestorePaths.library(uid, libraryId)),
      _libraryData(
        name: libraryName.trim(),
        ownerName: profile['displayName'] as String? ?? '',
        email: profile['email'] as String? ?? '',
        phone: phone ?? profile['phone'] as String? ?? '',
      ),
    );
    batch.update(_firestore.doc(FirestorePaths.user(uid)), {
      'currentLibraryId': libraryId,
      'profile.updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  @override
  Future<void> switchCurrentLibrary(String uid, String libraryId) async {
    final target = await _firestore
        .doc(FirestorePaths.library(uid, libraryId))
        .get();
    if (!target.exists) throw const ValidationException('Library not found.');
    await _firestore.doc(FirestorePaths.user(uid)).update({
      'currentLibraryId': libraryId,
      'profile.updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _initializeUserAndLibrary({
    required User user,
    required String displayName,
    required String libraryName,
    required String phone,
  }) async {
    final libraryId = _newLibraryId();
    final now = FieldValue.serverTimestamp();
    final batch = _firestore.batch();
    batch.set(_firestore.doc(FirestorePaths.user(user.uid)), {
      'profile': {
        'displayName': displayName,
        'email': user.email ?? '',
        'phone': phone,
        'photoUrl': user.photoURL,
        'emailVerified': user.emailVerified,
        'role': 'owner',
        'createdAt': now,
        'updatedAt': now,
      },
      'currentLibraryId': libraryId,
    });
    batch.set(
      _firestore.doc(FirestorePaths.library(user.uid, libraryId)),
      _libraryData(
        name: libraryName,
        ownerName: displayName,
        email: user.email ?? '',
        phone: phone,
      ),
    );
    await batch.commit();
  }

  Map<String, dynamic> _libraryData({
    required String name,
    required String ownerName,
    required String email,
    required String phone,
  }) {
    return {
      'libraryInfo': {
        'name': name,
        'ownerName': ownerName,
        'email': email,
        'phone': phone,
      },
      'branding': {'logoUrl': null},
      'configuration': {'totalSeats': 0, 'subscriptionPlan': 'Trial'},
      'templates': <String, dynamic>{},
    };
  }

  String _newLibraryId() =>
      'lib_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('Your session has expired.');
    await user.sendEmailVerification();
  }

  @override
  Future<User?> reloadCurrentUser() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser;
  }

  @override
  Future<void> markEmailVerified(String uid) =>
      _firestore.doc(FirestorePaths.user(uid)).update({
        'profile.emailVerified': true,
        'profile.verificationCompletedAt': FieldValue.serverTimestamp(),
        'profile.updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
