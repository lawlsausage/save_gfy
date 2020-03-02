import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:save_gfy/services/file_service.dart';

class MockFile extends Mock implements File {
  MockFile({String filePath}) {
    if ((filePath?.length ?? 0) > 0) {
      when(this.path).thenReturn(filePath);
    }
  }
}

class MockFileService extends Mock implements FileService {
  MockFileService({this.mockFileFactory}) {
    if (this.mockFileFactory != null) {
      when(this.instance).thenReturn((filePath) => mockFileFactory(filePath));
    }
  }

  final File Function(String) mockFileFactory;
}
