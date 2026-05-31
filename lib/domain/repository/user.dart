import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/VerifyOtpPayload.dart';
import 'package:demo_app/data/models/pump_list_criteria.dart';
import 'package:demo_app/data/models/pump_station_history_criteria.dart';
import 'package:demo_app/data/models/update_name_payload.dart';
import 'package:demo_app/data/models/update_password_payload.dart';
import 'package:demo_app/data/models/update_phone_payload.dart';
import 'package:demo_app/data/models/user_block_payload.dart';
import 'package:demo_app/data/models/user_list_criteria.dart';

import '../../data/models/pump_execution_payload.dart';
import '../../data/models/transaction_history_criteria.dart';

abstract class UserRepository {
  Future<Either> userInfo();

  Future<Either> userInfoById(int id);

  Future<Either> updateName(UpdateNamePayload updateNamePayload);

  Future<Either> updateBlockingStatus(UserBlockPayload payload);

  Future<Either> updatePassword(UpdatePasswordPayload updateNamePayload);

  Future<Either> updatePhone(UpdatePhonePayload updatePhonePayload);

  Future<Either> verifyPhoneUpdateOTP(VerifyOtpPayload payload);

  Future<Either> transactionInfo(TransactionHistoryParams param);

  Future<Either> pumpStationHistory(PumpStationHistoryParam param);

  Future<Either> allPumpStationHistory(PumpStationHistoryParam param);

  Future<Either> pumpStationList(PumpStationCriteria criteria);

  Future<Either> allUserList(UserListCriteria criteria);
}
