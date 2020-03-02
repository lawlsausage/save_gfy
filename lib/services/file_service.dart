import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:save_gfy/services/logger_service.dart';

typedef File FileFactory(String filePath);

/// Provides helpful interactions with the underlying file system for reading or modifying
/// local file resources.
class FileService {
  FileService(this._fileFactory, this.loggerService,
      {@required this.appAssetBundle});

  final FileFactory _fileFactory;

  final LoggerService loggerService;

  final AssetBundle appAssetBundle;

  /// Loads a JSON file from the application's asset bundle via [FileService.appAssetBundle].
  /// If an error is encountered, [loadJsonFromFile] will return an empty [Map<String, dynamic>]
  /// object.
  Future<dynamic> loadJsonFromFile(String filePath) async {
    dynamic json = Map<String, dynamic>();
    try {
      String contents = await appAssetBundle.loadString(filePath);
      json = jsonDecode(contents);
    } catch (err) {
      loggerService.d('Unable to load JSON file.', err);
    }

    return json;
  }

  /// Creates a [File] instance from the [filePath] provided.
  ///
  /// If [path] is a relative path, it will be interpreted relative to the
  /// current working directory (see [Directory.current]), when used.
  ///
  /// If [path] is an absolute path, it will be immune to changes to the
  /// current working directory.
  File Function(String) get instance => (filePath) => _fileFactory(filePath);

  /// Deletes the file system instance of the [File] provided in the [file] parameter.
  /// If the [File] does not exist, no action is made. [deleteFileSync] wraps around
  /// the [File]'s [FileSystemEntity.deleteSync] method.
  ///
  /// The [File] is returned.
  File deleteFileSync(File file, {bool recursive}) {
    if (file?.existsSync() ?? false) {
      file.deleteSync(recursive: recursive);
    }
    return file;
  }
}
