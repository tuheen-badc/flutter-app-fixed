import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/domain/repository/user_image.dart';
import 'package:demo_app/service_locator.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfilePictureUseCase implements UseCase<Either, XFile> {
  @override
  Future<Either> call({XFile? param}) async {
    return serviceLocator<UserImageRepository>().uploadUserImage(param!);
  }
}
