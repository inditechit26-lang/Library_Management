/// The only place where Firestore collection and document paths are composed.
abstract final class FirestorePaths {
  static const users = 'users';

  static String user(String uid) => '$users/$uid';
  static String libraries(String uid) => '${user(uid)}/libraries';
  static String library(String uid, String libraryId) =>
      '${libraries(uid)}/$libraryId';

  static String students(String uid, String libraryId) =>
      '${library(uid, libraryId)}/students';
  static String seats(String uid, String libraryId) =>
      '${library(uid, libraryId)}/seats';
  static String admissions(String uid, String libraryId) =>
      '${library(uid, libraryId)}/admissions';
  static String payments(String uid, String libraryId) =>
      '${library(uid, libraryId)}/payments';
  static String receipts(String uid, String libraryId) =>
      '${library(uid, libraryId)}/receipts';
  static String reports(String uid, String libraryId) =>
      '${library(uid, libraryId)}/reports';
  static String documents(String uid, String libraryId) =>
      '${library(uid, libraryId)}/documents';
  static String announcements(String uid, String libraryId) =>
      '${library(uid, libraryId)}/announcements';
  static String activityLogs(String uid, String libraryId) =>
      '${library(uid, libraryId)}/activityLogs';
}
