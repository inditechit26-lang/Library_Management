enum StudentDocumentType { aadhaar, collegeId, passportPhoto, other }

class StudentDocument {
  final String id, name, path, uploadedAt;
  final StudentDocumentType type;
  final bool isImage;
  const StudentDocument({
    required this.id,
    required this.name,
    required this.path,
    required this.uploadedAt,
    required this.type,
    required this.isImage,
  });
}
