import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Handles camera/gallery capture and local image file management.
class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final _picker = ImagePicker();
  final _uuid = const Uuid();

  /// Launches the device camera and returns the captured XFile, or null if cancelled.
  Future<XFile?> captureFromCamera() async {
    return _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1920,
    );
  }

  /// Opens the gallery picker and returns the selected XFile, or null if cancelled.
  Future<XFile?> pickFromGallery() async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
    );
  }

  /// Copies an XFile into the app's documents directory for permanent storage.
  /// Returns the absolute path of the saved file.
  Future<String> saveImageLocally(XFile xFile) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final memoriesDir = Directory(p.join(docsDir.path, 'memories'));
    if (!await memoriesDir.exists()) {
      await memoriesDir.create(recursive: true);
    }
    final ext = p.extension(xFile.path).isEmpty ? '.jpg' : p.extension(xFile.path);
    final fileName = '${_uuid.v4()}$ext';
    final destPath = p.join(memoriesDir.path, fileName);
    await File(xFile.path).copy(destPath);
    return destPath;
  }
}
