import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/signup_payload.dart';
import 'package:demo_app/domain/repository/auth.dart';
import 'package:demo_app/domain/repository/user.dart';
import 'package:demo_app/service_locator.dart';

import '../../data/models/transaction_history_criteria.dart';

class UserTransactionUseCase implements UseCase<Either, TransactionHistoryParams> {
  @override
  Future<Either> call({TransactionHistoryParams? param}) async {
    return serviceLocator<UserRepository>().transactionInfo(param!);
  }
}
