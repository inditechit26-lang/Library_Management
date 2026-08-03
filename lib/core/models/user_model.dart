import 'package:cloud_firestore/cloud_firestore.dart';

class AppUserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String libraryId;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.libraryId,
    this.role = 'owner',
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final profile = Map<String, dynamic>.from(
      data['profile'] as Map? ?? const <String, dynamic>{},
    );
    return AppUserModel(
      uid: doc.id,
      email: profile['email'] ?? '',
      displayName: profile['displayName'] ?? '',
      photoUrl: profile['photoUrl'],
      libraryId: data['currentLibraryId'] ?? '',
      role: profile['role'] ?? 'owner',
      createdAt:
          (profile['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (profile['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'profile': {
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'role': role,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      },
      'currentLibraryId': libraryId,
    };
  }

  AppUserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? libraryId,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      libraryId: libraryId ?? this.libraryId,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
