import 'web_picker_stub.dart'
    if (dart.library.html) 'web_picker_web.dart';
import 'web_picker_interface.dart';

class WebFilePicker {
  static void pickFile(WebFilePickerCallback onSelected) {
    WebFilePickerImpl.pickFile(onSelected);
  }
}
