import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

abstract class UserImageRepository {
  Future<Either> uploadUserImage(XFile imageFile);
}
