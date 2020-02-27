import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:save_gfy/services/logger_service.dart';

class FileService {
  /// Loads a JSON file from the application's root asset bundle.
  Future<dynamic> loadJsonFile(String filePath) async {
    Map<String, dynamic> json = {};
    try {
      String contents = await rootBundle.loadString(filePath);
      json = jsonDecode(contents);
    } catch (err) {
      loggerService.d('Unable to load JSON file.', err);
    }

    return json;
  }

  File createFile(String path) {
    return File(path);
  }

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
