import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Helper service to capture or pick produce photos and save them to app storage.
class ProductImageService {
  final ImagePicker _picker;

  ProductImageService([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  /// Prompts user to pick an image from gallery or capture with camera.
  /// Saves the compressed image to persistent application documents directory.
  Future<String?> pickAndSaveImage({required ImageSource source}) async {
    try {
      final xFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (xFile == null) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(appDir.path, 'product_images'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final ext = p.extension(xFile.path).isNotEmpty
          ? p.extension(xFile.path)
          : '.jpg';
      final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}$ext';
      final targetPath = p.join(imagesDir.path, fileName);

      final savedFile = await File(xFile.path).copy(targetPath);
      return savedFile.path;
    } catch (_) {
      return null;
    }
  }

  /// Deletes a local product image file if it exists.
  Future<void> deleteImage(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
