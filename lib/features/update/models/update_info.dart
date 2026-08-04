import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateInfo {
  final bool enabled;
  final String latestVersion;
  final String minimumSupportedVersion;
  final String updateType;
  final String releaseDate;
  final String apkUrl;
  final String apkSize;
  final List<String> changelog;
  final bool forceUpdate;

  const UpdateInfo({
    required this.enabled,
    required this.latestVersion,
    required this.minimumSupportedVersion,
    required this.updateType,
    required this.releaseDate,
    required this.apkUrl,
    required this.apkSize,
    required this.changelog,
    required this.forceUpdate,
  });

  factory UpdateInfo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    // Parse changelog handling String, List or raw dynamic
    List<String> parsedChangelog = [];
    if (data['changelog'] is List) {
      parsedChangelog = (data['changelog'] as List).map((e) => e.toString()).toList();
    } else if (data['changelog'] is String) {
      parsedChangelog = (data['changelog'] as String)
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();
    }

    return UpdateInfo(
      enabled: data['enabled'] ?? true,
      latestVersion: data['latestVersion'] ?? '1.0.0',
      minimumSupportedVersion: data['minimumSupportedVersion'] ?? '1.0.0',
      updateType: data['updateType'] ?? 'Flexible',
      releaseDate: data['releaseDate'] ?? '',
      apkUrl: data['apkUrl'] ?? '',
      apkSize: data['apkSize'] ?? '',
      changelog: parsedChangelog,
      forceUpdate: data['forceUpdate'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'latestVersion': latestVersion,
      'minimumSupportedVersion': minimumSupportedVersion,
      'updateType': updateType,
      'releaseDate': releaseDate,
      'apkUrl': apkUrl,
      'apkSize': apkSize,
      'changelog': changelog,
      'forceUpdate': forceUpdate,
    };
  }
}
