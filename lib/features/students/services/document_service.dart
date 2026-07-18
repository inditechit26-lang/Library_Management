import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class PickedStudentDocument {
  final String name, path;
  final bool isImage;
  const PickedStudentDocument(this.name, this.path, this.isImage);
}

class DocumentService {
  final ImagePicker _images = ImagePicker();
  Future<PickedStudentDocument?> fromCamera() async {
    final file = await _images.pickImage(
      source: ImageSource.camera,
      imageQuality: 88,
    );
    return file == null
        ? null
        : PickedStudentDocument(file.name, file.path, true);
  }

  Future<PickedStudentDocument?> fromGallery() async {
    final file = await _images.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
    );
    return file == null
        ? null
        : PickedStudentDocument(file.name, file.path, true);
  }

  Future<PickedStudentDocument?> fromFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final file = result?.files.single;
    return file?.path == null
        ? null
        : PickedStudentDocument(
            file!.name,
            file.path!,
            !file.extension!.toLowerCase().contains('pdf'),
          );
  }
}
