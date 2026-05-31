import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/user_tier_list.dart';
import 'package:demo_app/data/source/user_tier_api_service.dart';
import 'package:demo_app/domain/repository/user_tier.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';

class UserTierRepositoryImplementation extends UserTierRepository {
  @override
  Future<Either> getUserTier(int userId) async {
    Either result = await serviceLocator<UserTierApiService>().getUserTier(userId);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        List<dynamic> jsonData = response.data;
        List<PumpStationTierInfo> usagesAnalytics = jsonData
            .map((row) => PumpStationTierInfo.fromJson(row))
            .toList();
        return Right(usagesAnalytics);
      },
    );
  }
}
