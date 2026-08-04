import 'package:cloud_firestore/cloud_firestore.dart';

/// Seed default appUpdate/android document in Firestore if missing
Future<void> seedAppUpdateDocument() async {
  try {
    final docRef = FirebaseFirestore.instance.collection('appUpdate').doc('android');
    final snapshot = await docRef.get();
    
    if (!snapshot.exists) {
      await docRef.set({
        'enabled': true,
        'latestVersion': '1.0.0',
        'minimumSupportedVersion': '1.0.0',
        'updateType': 'Flexible',
        'releaseDate': DateTime.now().toString().split(' ')[0],
        'apkUrl': 'https://example.com/latest.apk',
        'apkSize': '45 MB',
        'changelog': [
          '• Initial Release',
          '• Student & Seat Management',
          '• Automated Fees & Receipts',
        ],
        'forceUpdate': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('[AppUpdate] Initialized appUpdate/android document in Firestore.');
    }
  } catch (e) {
    print('[AppUpdate] Error initializing document: $e');
  }
}
