import 'package:dartz/dartz.dart';
import 'package:demo_app/core/constants/api_urls.dart';
import 'package:demo_app/core/network/dio_client.dart';
import 'package:demo_app/data/models/forgot_password_payload.dart';
import 'package:demo_app/data/models/login_payload.dart';
import 'package:demo_app/data/models/reset_password_payload.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';

import '../models/VerifyOtpPayload.dart';
import '../models/signup_payload.dart';

abstract class AuthApiService {
  Future<Either> signup(SignUpPayload signUpPayload);

  Future<Either> login(LoginPayload loginPayload);

  Future<Either> forgotPassword(ForgotPasswordPayload payload);

  Future<Either> resetPassword(ResetPasswordPayload payload);

  Future<Either> verifyOtpForRegistration(VerifyOtpPayload payload);

  Future<Either> verifyOtpForForgotPassword(VerifyOtpPayload payload);
}

class AuthApiServiceImplementation extends AuthApiService {
  @override
  Future<Either> signup(SignUpPayload signUpPayload) async {
    try {
      var response = await serviceLocator<DioClient>().post(
        ApiUrls.register,
        data: signUpPayload.toMap(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> login(LoginPayload loginPayload) async {
    try {
      var response = await serviceLocator<DioClient>().post(
        ApiUrls.login,
        data: loginPayload.toMap(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either> forgotPassword(ForgotPasswordPayload payload) async {
    try {
      var response = await serviceLocator<DioClient>().post(
        ApiUrls.forgotPassword,
        data: payload.toMap(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either> resetPassword(ResetPasswordPayload payload) async {
    try {
      var response = await serviceLocator<DioClient>().post(
        ApiUrls.resetPassword,
        data: payload.toMap(),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either> verifyOtpForRegistration(VerifyOtpPayload payload) async {
    try {
      Response response = await serviceLocator<DioClient>().post(
        ApiUrls.verifyRegistration,
        data: payload.toMap(),
      );

      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }

  @override
  Future<Either> verifyOtpForForgotPassword(VerifyOtpPayload payload) async {
    try {
      Response response = await serviceLocator<DioClient>().post(
        ApiUrls.verifyForgotPassword,
        data: payload.toMap(),
      );

      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.data['message']);
    }
  }
}
