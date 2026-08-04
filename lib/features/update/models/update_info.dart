import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateInfo {
  final bool enabled;
  final String latestVersion;
  final String minimumSupportedVersion;
  final String releaseDate;
  final String apkUrl;
  final String apkSize;
  final bool forceUpdate;

  const UpdateInfo({
    required this.enabled,
    required this.latestVersion,
    required this.minimumSupportedVersion,
    required this.releaseDate,
    required this.apkUrl,
    required this.apkSize,
    required this.forceUpdate,
  });

  factory UpdateInfo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return UpdateInfo(
      enabled: data['enabled'] ?? true,
      latestVersion: data['latestVersion'] ?? '1.0.0',
      minimumSupportedVersion: data['minimumSupportedVersion'] ?? '1.0.0',
      releaseDate: data['releaseDate'] ?? '',
      apkUrl: data['apkUrl'] ?? '',
      apkSize: data['apkSize'] ?? '',
      forceUpdate: data['forceUpdate'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'latestVersion': latestVersion,
      'minimumSupportedVersion': minimumSupportedVersion,
      'releaseDate': releaseDate,
      'apkUrl': apkUrl,
      'apkSize': apkSize,
      'forceUpdate': forceUpdate,
    };
  }
}
