import 'package:dartz/dartz.dart';
import 'package:demo_app/core/constants/api_urls.dart';
import 'package:demo_app/core/network/dio_client.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class UserCreditApiService {
  Future<Either> userCreditInfo();
}

class UserCreditApiServiceImplementation extends UserCreditApiService {
  @override
  Future<Either> userCreditInfo() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');
      var response = await serviceLocator<DioClient>().get(
        ApiUrls.creditInfo,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }
}
