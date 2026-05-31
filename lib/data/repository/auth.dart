import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/error_model.dart';
import 'package:demo_app/data/models/forgot_password_payload.dart';
import 'package:demo_app/data/models/login_payload.dart';
import 'package:demo_app/data/models/reset_password_payload.dart';
import 'package:demo_app/data/models/signup_payload.dart';
import 'package:demo_app/data/source/auth_api_service.dart';
import 'package:demo_app/domain/repository/auth.dart';
import 'package:demo_app/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/VerifyOtpPayload.dart';
import '../models/verify_forgot_password_response.dart';

class AuthRepositoryImplementation extends AuthRepository {
  @override
  Future<Either> signup(SignUpPayload signUpPayload) async {
    Either result = await serviceLocator<AuthApiService>().signup(
      signUpPayload,
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
  Future<Either> login(LoginPayload loginPayload) async {
    Either result = await serviceLocator<AuthApiService>().login(loginPayload);
    return result.fold(
      (error) {
        final errorData = error.response?.data;
        return Left(ErrorModel.fromJson(errorData));
      },
      (data) async {
        Response response = data;
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString('token', response.data['token']);
        return Right(response);
      },
    );
  }

  @override
  Future<Either> forgotPassword(ForgotPasswordPayload payload) async {
    Either result = await serviceLocator<AuthApiService>().forgotPassword(
      payload,
    );
    return result.fold(
      (error) {
        final errorData = error.response?.data;
        return Left(ErrorModel.fromJson(errorData));
      },
      (data) async {
        Response response = data;
        return Right(response);
      },
    );
  }

  @override
  Future<Either> resetPassword(ResetPasswordPayload payload) async {
    Either result = await serviceLocator<AuthApiService>().resetPassword(
      payload,
    );
    return result.fold(
      (error) {
        final errorData = error.response?.data;
        return Left(ErrorModel.fromJson(errorData));
      },
      (data) async {
        Response response = data;
        return Right(response);
      },
    );
  }

  @override
  Future<Either> verifyOtpForRegistration(VerifyOtpPayload payload) async {
    Either result = await serviceLocator<AuthApiService>()
        .verifyOtpForRegistration(payload);
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
  Future<Either> verifyOtpForForgotPassword(VerifyOtpPayload payload) async {
    Either result = await serviceLocator<AuthApiService>()
        .verifyOtpForForgotPassword(payload);
    return result.fold(
      (error) {
        return Left(error);
      },
      (data) async {
        Response response = data;
        return Right(VerifyForgotPasswordResponse.fromJson(response.data));
      },
    );
  }
}
