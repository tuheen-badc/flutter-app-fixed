// lib/domain/usecases/get_all_complaints_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/service_locator.dart';

import '../../data/models/complaint.dart';
import '../repository/complaint.dart';

class GetAllComplaintsUseCase implements UseCase<Either, ComplaintCriteria> {
  @override
  Future<Either> call({ComplaintCriteria? param}) async {
    return serviceLocator<ComplaintRepository>().getAllComplaints(param!);
  }
}
