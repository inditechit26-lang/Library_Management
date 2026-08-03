import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_flutter/core/services/firestore_paths.dart';

void main() {
  const uid = 'user-a';
  const library = 'library-b';
  const root = 'users/user-a/libraries/library-b';

  test('every tenant collection is isolated below its user and library', () {
    final paths = [
      FirestorePaths.students(uid, library),
      FirestorePaths.seats(uid, library),
      FirestorePaths.admissions(uid, library),
      FirestorePaths.payments(uid, library),
      FirestorePaths.receipts(uid, library),
      FirestorePaths.reports(uid, library),
      FirestorePaths.documents(uid, library),
      FirestorePaths.announcements(uid, library),
      FirestorePaths.activityLogs(uid, library),
    ];

    for (final path in paths) {
      expect(path, startsWith('$root/'));
      expect(path, isNot(startsWith('libraries/')));
    }
  });

  test('user and library document paths use the approved hierarchy', () {
    expect(FirestorePaths.user(uid), 'users/user-a');
    expect(FirestorePaths.libraries(uid), 'users/user-a/libraries');
    expect(FirestorePaths.library(uid, library), root);
  });
}
