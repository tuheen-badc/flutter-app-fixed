// firmware_upload_request.dart
import 'dart:io';

class FirmwareUploadRequest {
  final String version;
  final File file;

  FirmwareUploadRequest({required this.version, required this.file});
}
