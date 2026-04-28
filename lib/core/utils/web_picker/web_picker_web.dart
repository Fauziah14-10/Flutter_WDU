import 'dart:html' as html;
import 'dart:typed_data';
import 'web_picker_interface.dart';

class WebFilePickerImpl {
  static void pickFile(WebFilePickerCallback onSelected) {
    final input = html.FileUploadInputElement();
    input.accept = 'image/*,audio/*,video/*,.pdf,.doc,.docx';
    input.click();

    input.onChange.listen((event) {
      if (input.files!.isEmpty) return;
      
      final file = input.files!.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((event) {
        final bytes = reader.result as Uint8List;
        final blobUrl = html.Url.createObjectUrlFromBlob(file);
        onSelected(file.name, bytes, blobUrl);
      });
    });
  }
}
