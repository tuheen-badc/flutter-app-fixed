import 'package:dartz/dartz.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:demo_app/data/models/ComplaintCreationModel.dart';
import 'package:demo_app/domain/repository/complaint.dart';
import 'package:demo_app/service_locator.dart';

class SubmitComplaintUseCase
    implements UseCase<Either, ComplaintCreationModel> {
  @override
  Future<Either> call({ComplaintCreationModel? param}) async {
    return serviceLocator<ComplaintRepository>().submitComplaint(param!);
  }
}
