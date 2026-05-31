import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/VerifyOtpPayload.dart';
import 'package:demo_app/data/models/pump_list_criteria.dart';
import 'package:demo_app/data/models/pump_station_histories.dart';
import 'package:demo_app/data/models/pump_station_history_criteria.dart';
import 'package:demo_app/data/models/transactions.dart';
import 'package:demo_app/data/models/update_name_payload.dart';
import 'package:demo_app/data/models/update_password_payload.dart';
import 'package:demo_app/data/models/update_phone_payload.dart';
import 'package:demo_app/data/models/user_block_payload.dart';
import 'package:demo_app/data/models/user_list_criteria.dart';
import 'package:demo_app/data/models/user_list_response.dart';
import 'package:demo_app/data/source/user_api_service.dart';
import 'package:demo_app/domain/repository/user.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';

import '../models/pump_station_list.dart';
import '../models/transaction_history_criteria.dart';
import '../models/user_info.dart';

class UserRepositoryImplementation extends UserRepository {
  @override
  Future<Either> userInfo() async {
    Either result = await serviceLocator<UserApiService>().userInfo();
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(User.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> userInfoById(int id) async {
    Either result = await serviceLocator<UserApiService>().userInfoById(id);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(User.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> updateName(UpdateNamePayload updateNamePayload) async {
    Either result = await serviceLocator<UserApiService>().updateName(
      updateNamePayload,
    );
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(response);
      },
    );
  }

  @override
  Future<Either> updateBlockingStatus(UserBlockPayload payload) async {
    Either result = await serviceLocator<UserApiService>()
        .updateUserBlockingStatus(payload);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(response);
      },
    );
  }

  @override
  Future<Either> updatePassword(
    UpdatePasswordPayload updatePasswordPayload,
  ) async {
    Either result = await serviceLocator<UserApiService>().updatePassword(
      updatePasswordPayload,
    );
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(response);
      },
    );
  }

  @override
  Future<Either> updatePhone(UpdatePhonePayload updatePhonePayload) async {
    Either result = await serviceLocator<UserApiService>().updatePhone(
      updatePhonePayload,
    );
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(response);
      },
    );
  }

  @override
  Future<Either> verifyPhoneUpdateOTP(VerifyOtpPayload payload) async {
    Either result = await serviceLocator<UserApiService>().verifyPhoneUpdateOtp(payload);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(response);
      },
    );
  }

  @override
  Future<Either> transactionInfo(TransactionHistoryParams param) async {
    Either result = await serviceLocator<UserApiService>().transactionInfo(
      param,
    );
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(RechargeHistoryResponse.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> pumpStationHistory(PumpStationHistoryParam param) async {
    Either result = await serviceLocator<UserApiService>().pumpStationHistory(
      param,
    );
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(PumpStationHistoryResponse.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> allPumpStationHistory(PumpStationHistoryParam param) async {
    Either result = await serviceLocator<UserApiService>()
        .allPumpStationHistory(param);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(PumpStationHistoryResponse.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> pumpStationList(PumpStationCriteria criteria) async {
    Either result = await serviceLocator<UserApiService>().pumpStationList(
      criteria,
    );
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(PumpStationResponse.fromJson(response.data));
      },
    );
  }

  @override
  Future<Either> allUserList(UserListCriteria criteria) async {
    Either result = await serviceLocator<UserApiService>().allUserList(
      criteria,
    );
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(UserListResponse.fromJson(response.data));
      },
    );
  }
}
