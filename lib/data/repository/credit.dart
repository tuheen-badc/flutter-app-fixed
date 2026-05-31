import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/credit_info.dart';
import 'package:demo_app/data/source/user_credit_api_service.dart';
import 'package:demo_app/domain/repository/credit.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';

class CreditRepositoryImplementation extends CreditRepository {
  @override
  Future<Either> userCreditInfo() async {
    Either result = await serviceLocator<UserCreditApiService>()
        .userCreditInfo();
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(UserCreditResponseModel.fromJson(response.data));
      },
    );
  }
}
