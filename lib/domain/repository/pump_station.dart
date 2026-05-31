import 'package:dartz/dartz.dart';
import 'package:demo_app/data/models/single_pump_station_history_criteria.dart';

import '../../data/models/pump_execution_payload.dart';
import '../../data/models/pump_list_criteria.dart';
import '../../data/models/pump_station_creation_payload.dart';
import '../../data/models/pump_station_update_payload.dart';
import '../../data/models/user_of_pump_station.dart';

abstract class PumpStationRepository {
  Future<Either> pumpExecutionRequest(PumpExecutionPayload payload);

  Future<Either> pumpStationBasicList();

  Future<Either> allPumpStationList(PumpStationCriteria criteria);

  Future<Either> singlePumpStationHistory(SinglePumpStationHistoryParam param);

  Future<Either> userOfPumpStation(UserOfPumpStationParam param);

  Future<Either> getPumpStationById(int pumpStationId);

  Future<Either> getPumpLiveStatus(int userId);

  Future<Either> updatePumpLocation(UpdatePumpLocationPayload payload);

  Future<Either> updateManagerPhone(UpdateManagerPhonePayload payload);

  Future<Either> updateDataProviderPhone(
    UpdateDataProviderPhonePayload payload,
  );

  Future<Either> createPumpStation(PumpStationCreationPayload payload);
}
