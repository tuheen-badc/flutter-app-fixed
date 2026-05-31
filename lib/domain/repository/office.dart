// office_repository.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/office_creation_payload.dart';

import '../../data/models/office_detail_model.dart';
import '../../data/models/office_fetch_criteria.dart';
import '../../data/models/office_pump_criteria.dart';
import '../../data/models/office_user_list_criteria.dart';

abstract class OfficeRepository {
  Future<Either> allOfficeList(OfficeCriteria criteria);

  Future<Either> officeUserList(OfficeUserListCriteria criteria);

  Future<Either> officePumpList(OfficePumpCriteria criteria);

  Future<Either> getOfficeDetail(int officeId);

  Future<Either> updateOfficeLocation(UpdateOfficeLocationPayload payload);

  Future<Either> updateOfficeContact(UpdateOfficeContactPayload payload);

  Future<Either> createOffice(OfficeCreationPayload officeCreationPayload);
}
