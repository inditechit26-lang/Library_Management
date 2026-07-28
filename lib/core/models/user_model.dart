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
    return AppUserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      libraryId: data['libraryId'] ?? '',
      role: data['role'] ?? 'owner',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'libraryId': libraryId,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
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
