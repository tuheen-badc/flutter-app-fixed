import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/official_pre_registration_criteria.dart';
import 'package:demo_app/data/models/official_pre_registration_payload.dart';

import '../../data/models/pre_registration_deletion_param.dart';

abstract class PreRegistrationRepository {
  Future<Either> allPreRegistration(OfficialPreRegistrationCriteria criteria);

  Future<Either> deletePreRegistration(PreRegistrationDeletionParam param);

  Future<Either> createPreRegistration(OfficialPreRegistrationPayload payload);
}
