import 'package:dartz/dartz.dart';
import 'package:demo_app/core/constants/api_urls.dart';
import 'package:demo_app/core/network/dio_client.dart';
import 'package:demo_app/data/models/VerifyOtpPayload.dart';
import 'package:demo_app/data/models/pump_list_criteria.dart';
import 'package:demo_app/data/models/pump_station_history_criteria.dart';
import 'package:demo_app/data/models/update_name_payload.dart';
import 'package:demo_app/data/models/update_password_payload.dart';
import 'package:demo_app/data/models/update_phone_payload.dart';
import 'package:demo_app/data/models/user_block_payload.dart';
import 'package:demo_app/data/models/user_list_criteria.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_history_criteria.dart';

abstract class UserApiService {
  Future<Either> userInfo();

  Future<Either> userInfoById(int id);

  Future<Either> transactionInfo(TransactionHistoryParams param);

  Future<Either> pumpStationHistory(PumpStationHistoryParam param);

  Future<Either> allPumpStationHistory(PumpStationHistoryParam param);

  Future<Either> pumpStationList(PumpStationCriteria criteria);

  Future<Either> allUserList(UserListCriteria criteria);

  Future<Either> updateName(UpdateNamePayload payload);

  Future<Either> updateUserBlockingStatus(UserBlockPayload payload);

  Future<Either> updatePassword(UpdatePasswordPayload payload);

  Future<Either> updatePhone(UpdatePhonePayload payload);

  Future<Either> verifyPhoneUpdateOtp(VerifyOtpPayload payload);
}

class UserApiServiceImplementation extends UserApiService {
  @override
  Future<Either> userInfo() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.loggedInUserInfo,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> userInfoById(int id) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.userInfoById(id),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> updateName(UpdateNamePayload payload) async {
    try {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      final token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().patch(
        ApiUrls.userNameUpdate,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/vnd.update.name+json',
          },
        ),
        data: payload.toMap(),
      );

      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> updateUserBlockingStatus(UserBlockPayload payload) async {
    try {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      final token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().patch(
        ApiUrls.updateBlockingStatus(payload.userId),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/vnd.update.blockingStatus+json',
          },
        ),
        data: payload.toJson(),
      );

      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> updatePassword(UpdatePasswordPayload payload) async {
    try {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      final token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().patch(
        ApiUrls.userPasswordUpdate,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/vnd.update.password+json',
          },
        ),
        data: payload.toMap(),
      );

      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> updatePhone(UpdatePhonePayload payload) async {
    try {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      final token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().patch(
        ApiUrls.userPhoneUpdate,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/vnd.update.phone+json',
          },
        ),
        data: payload.toMap(),
      );

      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> verifyPhoneUpdateOtp(VerifyOtpPayload payload) async {
    try {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      final token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().post(
        ApiUrls.verifyPhoneUpdate,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: payload.toMap(),
      );

      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> transactionInfo(TransactionHistoryParams param) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.userCreditHistories(param.userId!),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: param.toMap(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> pumpStationHistory(PumpStationHistoryParam param) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.userPumpUsagesHistories(param.userId!),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: param.toJson(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> allPumpStationHistory(PumpStationHistoryParam param) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.allPumpStationHistory,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: param.toJson(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> pumpStationList(PumpStationCriteria criteria) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.userPumpStationList(criteria.userId!),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: criteria.toMap(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> allUserList(UserListCriteria criteria) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');

      Response response = await serviceLocator<DioClient>().get(
        ApiUrls.allUsers,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: criteria.toQueryParams(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }
}
