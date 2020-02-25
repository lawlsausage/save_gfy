import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:save_gfy/services/logger_service.dart';

class FileService {
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
}
