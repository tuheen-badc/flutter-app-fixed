import 'package:dartz/dartz.dart';
import 'package:demo_app/core/constants/api_urls.dart';
import 'package:demo_app/core/network/dio_client.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class UserImageApiService {
  Future<Either> uploadImage(XFile imageFile);
}

class UserImageApiServiceImplementation extends UserImageApiService {
  @override
  Future<Either> uploadImage(XFile imageFile) async {
    try {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      final token = sharedPreferences.getString('token');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.name,
          contentType: DioMediaType.parse(imageFile.mimeType ?? 'image/jpeg'),
        ),
      });

      Response response = await serviceLocator<DioClient>().patch(
        ApiUrls.loggedInUserImage,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
        data: formData,
      );

      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }
}
