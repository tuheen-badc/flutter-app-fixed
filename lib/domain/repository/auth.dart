import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/forgot_password_payload.dart';
import 'package:demo_app/data/models/login_payload.dart';
import 'package:demo_app/data/models/reset_password_payload.dart';
import 'package:demo_app/data/models/signup_payload.dart';

import '../../data/models/VerifyOtpPayload.dart';

abstract class AuthRepository {
  Future<Either> signup(SignUpPayload signUpPayload);

  Future<Either> login(LoginPayload loginPayload);

  Future<Either> forgotPassword(ForgotPasswordPayload payload);

  Future<Either> resetPassword(ResetPasswordPayload payload);

  Future<Either> verifyOtpForRegistration(VerifyOtpPayload payload);

  Future<Either> verifyOtpForForgotPassword(VerifyOtpPayload payload);
}
