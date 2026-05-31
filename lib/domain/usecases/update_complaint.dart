// lib/domain/usecases/update_complaint_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/service_locator.dart';

import '../../data/models/complaint.dart';
import '../repository/complaint.dart';

class UpdateComplaintParams {
  final int complaintId;
  final ComplaintUpdateModel updateModel;

  UpdateComplaintParams({required this.complaintId, required this.updateModel});
}

class UpdateComplaintUseCase implements UseCase<Either, UpdateComplaintParams> {
  @override
  Future<Either> call({UpdateComplaintParams? param}) async {
    return serviceLocator<ComplaintRepository>().updateComplaint(
      param!.complaintId,
      param.updateModel,
    );
  }
}
