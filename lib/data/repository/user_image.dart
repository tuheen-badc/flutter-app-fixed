import 'package:dartz/dartz.dart';
import 'package:demo_app/domain/repository/user_image.dart';
import 'package:demo_app/service_locator.dart';
import 'package:image_picker/image_picker.dart';

import '../source/user_image_api_service.dart';

class UserImageRepositoryImplementation extends UserImageRepository {
  @override
  Future<Either> uploadUserImage(XFile imageFile) async {
    Either result = await serviceLocator<UserImageApiService>().uploadImage(
      imageFile,
    );
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        return Right(unit);
      },
    );
  }
}
