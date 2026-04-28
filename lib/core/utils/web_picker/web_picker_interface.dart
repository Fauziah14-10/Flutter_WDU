import 'dart:typed_data';

typedef WebFilePickerCallback = void Function(String name, Uint8List bytes, String blobUrl);

abstract class WebFilePicker {
  static void pickFile(WebFilePickerCallback onSelected) {
    throw UnimplementedError('WebFilePicker is only supported on Web');
  }
}
