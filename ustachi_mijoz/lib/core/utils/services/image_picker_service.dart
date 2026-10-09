import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<PlatformFile?> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;

    return PlatformFile(
      path: image.path,
      name: image.name,
      size: await image.length(),
    );
  }

  Future<PlatformFile?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    return PlatformFile(
      path: image.path,
      name: image.name,
      size: await image.length(),
    );
  }
}
