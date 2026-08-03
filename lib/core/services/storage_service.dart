import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../exceptions/app_exception.dart';
import '../utils/error_handler.dart';

class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  /// Uploads a file to Firebase Storage and returns the public download URL
  Future<String> uploadFile({
    required String libraryId,
    required String folderName,
    required String fileName,
    required File file,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      final ref = _storage
          .ref()
          .child('users')
          .child(uid)
          .child('libraries')
          .child(libraryId)
          .child(folderName)
          .child(fileName);

      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e, stack) {
      throw ErrorHandler.handle(
        UploadException('Failed to upload file $fileName to storage.'),
        stack,
      );
    }
  }

  /// Uploads raw bytes (e.g. generated PDF documents)
  Future<String> uploadBytes({
    required String libraryId,
    required String folderName,
    required String fileName,
    required Uint8List bytes,
    String contentType = 'application/pdf',
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      final ref = _storage
          .ref()
          .child('users')
          .child(uid)
          .child('libraries')
          .child(libraryId)
          .child(folderName)
          .child(fileName);

      final metadata = SettableMetadata(contentType: contentType);
      final uploadTask = await ref.putData(bytes, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e, stack) {
      throw ErrorHandler.handle(
        UploadException('Failed to upload PDF bytes for $fileName.'),
        stack,
      );
    }
  }

  /// Deletes a file from storage by its download URL
  Future<void> deleteFileByUrl(String url) async {
    if (url.isEmpty) return;
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('Non-fatal storage deletion error: $e');
    }
  }
}
