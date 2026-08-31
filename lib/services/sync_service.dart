import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _uuid = const Uuid();

  /// Fetches the [count] most recent images from the device gallery.
  /// Copies them to the app's local directory and returns the files.
  Future<List<File>> getRecentImages({int count = 10}) async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    
    // On Android 13+ the user can grant LIMITED access — still usable
    if (!ps.hasAccess && ps != PermissionState.limited) {
      // Permission fully denied — open settings so user can grant it
      await PhotoManager.openSetting();
      return [];
    }

    // Get all image albums
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );
    
    if (albums.isEmpty) return [];

    final AssetPathEntity recentAlbum = albums.first;
    
    // Get the most recent `count` images
    final List<AssetEntity> recentAssets = await recentAlbum.getAssetListPaged(
      page: 0,
      size: count,
    );

    List<File> files = [];
    final docsDir = await getApplicationDocumentsDirectory();
    final memoriesDir = Directory(p.join(docsDir.path, 'memories'));
    if (!await memoriesDir.exists()) {
      await memoriesDir.create(recursive: true);
    }

    for (final asset in recentAssets) {
      final file = await asset.file;
      if (file != null) {
        // Copy to our app dir so we own it
        final ext = p.extension(file.path).isEmpty ? '.jpg' : p.extension(file.path);
        final fileName = '${_uuid.v4()}$ext';
        final destPath = p.join(memoriesDir.path, fileName);
        final savedFile = await file.copy(destPath);
        files.add(savedFile);
      }
    }

    return files;
  }
}
