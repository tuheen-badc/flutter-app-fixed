import 'package:demo_app/core/network/dio_client.dart';
import 'package:demo_app/data/repository/analytics.dart';
import 'package:demo_app/data/repository/auth.dart';
import 'package:demo_app/data/repository/complaint.dart';
import 'package:demo_app/data/repository/credit.dart';
import 'package:demo_app/data/repository/electricity_status.dart';
import 'package:demo_app/data/repository/firmware.dart';
import 'package:demo_app/data/repository/land_allocation.dart';
import 'package:demo_app/data/repository/office.dart';
import 'package:demo_app/data/repository/pre_registration.dart';
import 'package:demo_app/data/repository/pump_station.dart';
import 'package:demo_app/data/repository/user.dart';
import 'package:demo_app/data/repository/user_image.dart';
import 'package:demo_app/data/repository/user_tier.dart';
import 'package:demo_app/data/repository/water_budget.dart';
import 'package:demo_app/data/repository/water_pricing.dart';
import 'package:demo_app/data/repository/water_usages_report.dart';
import 'package:demo_app/data/source/analytics_api_service.dart';
import 'package:demo_app/data/source/auth_api_service.dart';
import 'package:demo_app/data/source/complaint_api_service.dart';
import 'package:demo_app/data/source/electricity_status_api_service.dart';
import 'package:demo_app/data/source/firmware_api_service.dart';
import 'package:demo_app/data/source/land_allocation_api_service.dart';
import 'package:demo_app/data/source/office_api_service.dart';
import 'package:demo_app/data/source/pre_registration_api_service.dart';
import 'package:demo_app/data/source/pump_station_api_service.dart';
import 'package:demo_app/data/source/user_credit_api_service.dart';
import 'package:demo_app/data/source/user_image_api_service.dart';
import 'package:demo_app/data/source/user_tier_api_service.dart';
import 'package:demo_app/data/source/water_budget_api_service.dart';
import 'package:demo_app/data/source/water_pricing_api_service.dart';
import 'package:demo_app/data/source/water_usages_report_api_service.dart';
import 'package:demo_app/domain/repository/analytics.dart';
import 'package:demo_app/domain/repository/auth.dart';
import 'package:demo_app/domain/repository/complaint.dart';
import 'package:demo_app/domain/repository/credit.dart';
import 'package:demo_app/domain/repository/electricity_status.dart';
import 'package:demo_app/domain/repository/firmware.dart';
import 'package:demo_app/domain/repository/land-allocation.dart';
import 'package:demo_app/domain/repository/office.dart';
import 'package:demo_app/domain/repository/pre_registration.dart';
import 'package:demo_app/domain/repository/pump_station.dart';
import 'package:demo_app/domain/repository/user.dart';
import 'package:demo_app/domain/repository/user_image.dart';
import 'package:demo_app/domain/repository/user_tier.dart';
import 'package:demo_app/domain/repository/water_budget.dart';
import 'package:demo_app/domain/repository/water_pricing.dart';
import 'package:demo_app/domain/repository/water_usages_report.dart';
import 'package:demo_app/domain/usecases/all_complaints.dart';
import 'package:demo_app/domain/usecases/all_office_list.dart';
import 'package:demo_app/domain/usecases/all_pump_station_history.dart';
import 'package:demo_app/domain/usecases/complaint_submission.dart';
import 'package:demo_app/domain/usecases/create_office.dart';
import 'package:demo_app/domain/usecases/create_pump_station.dart';
import 'package:demo_app/domain/usecases/electricity_history.dart';
import 'package:demo_app/domain/usecases/electricity_status.dart';
import 'package:demo_app/domain/usecases/firmware_history.dart';
import 'package:demo_app/domain/usecases/firmware_upload.dart';
import 'package:demo_app/domain/usecases/forgot_password.dart';
import 'package:demo_app/domain/usecases/land_allocation.dart';
import 'package:demo_app/domain/usecases/login.dart';
import 'package:demo_app/domain/usecases/office_analytics.dart';
import 'package:demo_app/domain/usecases/office_detail.dart';
import 'package:demo_app/domain/usecases/office_pump_list.dart';
import 'package:demo_app/domain/usecases/office_user_list.dart';
import 'package:demo_app/domain/usecases/overall_analytics.dart';
import 'package:demo_app/domain/usecases/pump_analytics.dart';
import 'package:demo_app/domain/usecases/pump_live_status.dart';
import 'package:demo_app/domain/usecases/pump_station_execution_request.dart';
import 'package:demo_app/domain/usecases/pump_station_history.dart';
import 'package:demo_app/domain/usecases/pump_station_list.dart';
import 'package:demo_app/domain/usecases/pump_usages_analytics.dart';
import 'package:demo_app/domain/usecases/reset_password.dart';
import 'package:demo_app/domain/usecases/sign_up.dart';
import 'package:demo_app/domain/usecases/single_pump_station_history.dart';
import 'package:demo_app/domain/usecases/update_complaint.dart';
import 'package:demo_app/domain/usecases/update_name.dart';
import 'package:demo_app/domain/usecases/update_password.dart';
import 'package:demo_app/domain/usecases/update_phone.dart';
import 'package:demo_app/domain/usecases/update_profile_picture.dart';
import 'package:demo_app/domain/usecases/user_block.dart';
import 'package:demo_app/domain/usecases/user_credit.dart';
import 'package:demo_app/domain/usecases/user_info.dart';
import 'package:demo_app/domain/usecases/user_info_by_id.dart';
import 'package:demo_app/domain/usecases/user_tier.dart';
import 'package:demo_app/domain/usecases/users_of_pump.dart';
import 'package:demo_app/domain/usecases/verify_forgot_password.dart';
import 'package:demo_app/domain/usecases/verify_phone_update.dart';
import 'package:demo_app/domain/usecases/verify_registration.dart';
import 'package:demo_app/domain/usecases/water_budget.dart';
import 'package:demo_app/domain/usecases/water_pricing.dart';
import 'package:demo_app/domain/usecases/water_usages_report.dart';
import 'package:get_it/get_it.dart';

import 'data/source/user_api_service.dart';
import 'domain/usecases/all_pump_station_list.dart';
import 'domain/usecases/all_user_list.dart';
import 'domain/usecases/pre_registration.dart';
import 'domain/usecases/pre_registration_create.dart';
import 'domain/usecases/pre_registration_delete.dart';
import 'domain/usecases/pump_station_detail.dart';
import 'domain/usecases/update_prcing.dart';
import 'domain/usecases/user_transaction.dart';

final serviceLocator = GetIt.instance;

void setupServiceLocator() {
  serviceLocator.registerSingleton<DioClient>(DioClient());

  //Service
  serviceLocator.registerSingleton<AuthApiService>(
    AuthApiServiceImplementation(),
  );
  serviceLocator.registerSingleton<WaterUsageReportApiService>(
    WaterUsageReportApiServiceImplementation(),
  );
  serviceLocator.registerSingleton<FirmwareApiService>(
    FirmwareApiServiceImplementation(),
  );
  serviceLocator.registerSingleton<AnalyticsApiService>(
    AnalyticsServiceImplementation(),
  );
  serviceLocator.registerSingleton<UserCreditApiService>(
    UserCreditApiServiceImplementation(),
  );
  serviceLocator.registerSingleton<UserApiService>(
    UserApiServiceImplementation(),
  );
  serviceLocator.registerSingleton<UserImageApiService>(
    UserImageApiServiceImplementation(),
  );
  serviceLocator.registerSingleton<PumpStationApiService>(
    PumpStationApiServiceImplementation(),
  );
  serviceLocator.registerSingleton<UserTierApiService>(
    UserTierApiServiceImplementation(),
  );
  serviceLocator.registerSingleton<WaterPricingApiService>(
    WaterPricingApiServiceImplementation(),
  );
  serviceLocator.registerSingleton<ElectricityStatusApiService>(
    ElectricityStatusServiceImplementation(),
  );
  serviceLocator.registerSingleton<WaterBudgetApiService>(
    WaterBudgetApiServiceImplementation(),
  );
  serviceLocator.registerSingleton<LandAllocationApiService>(
    LandAllocationApiServiceImplementation(),
  );
  serviceLocator.registerSingleton<PreRegistrationApiService>(
    PreRegistrationApiServiceImplementation(),
  );
  serviceLocator.registerSingleton<ComplaintApiService>(
    ComplaintApiServiceImplementation(),
  );
  serviceLocator.registerSingleton<OfficeApiService>(
    OfficeApiServiceImplementation(),
  );

  //Repository
  serviceLocator.registerSingleton<AuthRepository>(
    AuthRepositoryImplementation(),
  );
  serviceLocator.registerSingleton<WaterUsageReportRepository>(
    WaterUsageReportRepositoryImplementation(),
  );
  serviceLocator.registerSingleton<FirmwareRepository>(
    FirmwareRepositoryImplementation(),
  );
  serviceLocator.registerSingleton<AnalyticsRepository>(
    AnalyticsRepositoryImplementation(),
  );
  serviceLocator.registerSingleton<CreditRepository>(
    CreditRepositoryImplementation(),
  );
  serviceLocator.registerSingleton<UserRepository>(
    UserRepositoryImplementation(),
  );
  serviceLocator.registerSingleton<UserImageRepository>(
    UserImageRepositoryImplementation(),
  );
  serviceLocator.registerSingleton<PumpStationRepository>(
    PumpStationRepositoryImplementation(),
  );
  serviceLocator.registerSingleton<UserTierRepository>(
    UserTierRepositoryImplementation(),
  );
  serviceLocator.registerSingleton<WaterPricingRepository>(
    WaterPricingRepositoryImplementation(),
  );
  serviceLocator.registerSingleton<ElectricityStatusRepository>(
    ElectricityStatusRepositoryImplementation(),
  );
  serviceLocator.registerSingleton<WaterBudgetRepository>(
    WaterBudgetRepositoryImplementation(),
  );
  serviceLocator.registerSingleton<LandAllocationRepository>(
    LandAllocationRepositoryImplementation(),
  );

  serviceLocator.registerSingleton<PreRegistrationRepository>(
    PreRegistrationRepositoryImplementation(),
  );

  serviceLocator.registerSingleton<ComplaintRepository>(
    ComplaintRepositoryImplementation(),
  );
  serviceLocator.registerSingleton<OfficeRepository>(
    OfficeRepositoryImplementation(),
  );

  //UseCase
  serviceLocator.registerSingleton<SignUpUseCase>(SignUpUseCase());
  serviceLocator.registerSingleton<UpdateNameUseCase>(UpdateNameUseCase());
  serviceLocator.registerSingleton<UpdatePhoneUseCase>(UpdatePhoneUseCase());

  serviceLocator.registerSingleton<UpdateProfilePictureUseCase>(
    UpdateProfilePictureUseCase(),
  );
  serviceLocator.registerSingleton<VerifyPhoneUpdateUseCase>(
    VerifyPhoneUpdateUseCase(),
  );
  serviceLocator.registerSingleton<VerifyRegistrationUseCase>(
    VerifyRegistrationUseCase(),
  );
  serviceLocator.registerSingleton<ForgotPasswordUseCase>(
    ForgotPasswordUseCase(),
  );
  serviceLocator.registerSingleton<VerifyForgotPasswordUseCase>(
    VerifyForgotPasswordUseCase(),
  );
  serviceLocator.registerSingleton<ResetPasswordUseCase>(
    ResetPasswordUseCase(),
  );
  serviceLocator.registerSingleton<UpdatePasswordUseCase>(
    UpdatePasswordUseCase(),
  );
  serviceLocator.registerSingleton<LoginUseCase>(LoginUseCase());
  serviceLocator.registerSingleton<UserInfoUseCase>(UserInfoUseCase());
  serviceLocator.registerSingleton<UserTransactionUseCase>(
    (UserTransactionUseCase()),
  );
  serviceLocator.registerSingleton<PumpStationHistoryUseCase>(
    (PumpStationHistoryUseCase()),
  );
  serviceLocator.registerSingleton<AllPumpStationHistoryUseCase>(
    (AllPumpStationHistoryUseCase()),
  );
  serviceLocator.registerSingleton<PumpStationListUseCase>(
    (PumpStationListUseCase()),
  );
  serviceLocator.registerSingleton<AllPumpStationListUseCase>(
    (AllPumpStationListUseCase()),
  );
  serviceLocator.registerSingleton<PumpStationExecutionUseCase>(
    (PumpStationExecutionUseCase()),
  );
  serviceLocator.registerSingleton<UserCreditUseCase>(UserCreditUseCase());
  serviceLocator.registerSingleton<UserSpecificAnalyticsUseCase>(
    UserSpecificAnalyticsUseCase(),
  );
  serviceLocator.registerSingleton<UserTierUseCase>(UserTierUseCase());
  serviceLocator.registerSingleton<WaterPricingUseCase>(WaterPricingUseCase());
  serviceLocator.registerSingleton<ElectricityStatusUseCase>(
    ElectricityStatusUseCase(),
  );

  serviceLocator.registerSingleton<GetWaterBudgetUseCase>(
    GetWaterBudgetUseCase(),
  );

  serviceLocator.registerSingleton<UpdateWaterBudgetUseCase>(
    UpdateWaterBudgetUseCase(),
  );

  serviceLocator.registerSingleton<GetLandAllocationUseCase>(
    GetLandAllocationUseCase(),
  );
  serviceLocator.registerSingleton<CreateLandAllocationUseCase>(
    CreateLandAllocationUseCase(),
  );
  serviceLocator.registerSingleton<UpdateLandAllocationUseCase>(
    UpdateLandAllocationUseCase(),
  );
  serviceLocator.registerSingleton<DeleteLandAllocationUseCase>(
    DeleteLandAllocationUseCase(),
  );

  serviceLocator.registerSingleton<SinglePumpStationHistoryUseCase>(
    SinglePumpStationHistoryUseCase(),
  );

  serviceLocator.registerSingleton<UsersOfPumpUseCase>(UsersOfPumpUseCase());
  serviceLocator.registerSingleton<GetPumpStationDetailViewUseCase>(
    GetPumpStationDetailViewUseCase(),
  );

  serviceLocator.registerSingleton<UpdatePumpLocationUseCase>(
    UpdatePumpLocationUseCase(),
  );

  serviceLocator.registerSingleton<UpdateManagerPhoneUseCase>(
    UpdateManagerPhoneUseCase(),
  );
  serviceLocator.registerSingleton<UpdateDataProviderPhoneUseCase>(
    UpdateDataProviderPhoneUseCase(),
  );

  serviceLocator.registerSingleton<AllUserListUseCase>(AllUserListUseCase());
  serviceLocator.registerSingleton<OfficialPreRegistrationUseCase>(
    OfficialPreRegistrationUseCase(),
  );

  serviceLocator.registerSingleton<OfficialPreRegistrationDeleteUseCase>(
    OfficialPreRegistrationDeleteUseCase(),
  );

  serviceLocator.registerSingleton<OfficialPreRegistrationCreateUseCase>(
    OfficialPreRegistrationCreateUseCase(),
  );

  serviceLocator.registerSingleton<UserInfoByIdUseCase>(UserInfoByIdUseCase());
  serviceLocator.registerSingleton<UserBlockUseCase>(UserBlockUseCase());
  serviceLocator.registerSingleton<SubmitComplaintUseCase>(
    SubmitComplaintUseCase(),
  );
  serviceLocator.registerSingleton<GetAllComplaintsUseCase>(
    GetAllComplaintsUseCase(),
  );
  serviceLocator.registerSingleton<UpdateComplaintUseCase>(
    UpdateComplaintUseCase(),
  );

  serviceLocator.registerSingleton<OverallAnalyticsUseCase>(
    OverallAnalyticsUseCase(),
  );

  serviceLocator.registerSingleton<FirmwareUploadUseCase>(
    FirmwareUploadUseCase(),
  );
  serviceLocator.registerSingleton<FirmwareHistoryUseCase>(
    FirmwareHistoryUseCase(),
  );
  serviceLocator.registerSingleton<UpdateWaterPricingUseCase>(
    UpdateWaterPricingUseCase(),
  );

  serviceLocator.registerSingleton<AllOfficeListUseCase>(
    AllOfficeListUseCase(),
  );

  serviceLocator.registerSingleton<OfficeUserListUseCase>(
    OfficeUserListUseCase(),
  );

  serviceLocator.registerSingleton<OfficePumpListUseCase>(
    OfficePumpListUseCase(),
  );

  serviceLocator.registerSingleton<OfficeAnalyticsUseCase>(
    OfficeAnalyticsUseCase(),
  );

  serviceLocator.registerSingleton<PumpAnalyticsUseCase>(
    PumpAnalyticsUseCase(),
  );

  serviceLocator.registerSingleton<ElectricityHistoryUseCase>(
    ElectricityHistoryUseCase(),
  );

  serviceLocator.registerSingleton<PumpLiveStatusUseCase>(
    PumpLiveStatusUseCase(),
  );

  serviceLocator.registerSingleton<CreatePumpStationUseCase>(
    CreatePumpStationUseCase(),
  );

  serviceLocator.registerSingleton<GetOfficeDetailUseCase>(
    GetOfficeDetailUseCase(),
  );
  serviceLocator.registerSingleton<UpdateOfficeLocationUseCase>(
    UpdateOfficeLocationUseCase(),
  );
  serviceLocator.registerSingleton<UpdateOfficeContactUseCase>(
    UpdateOfficeContactUseCase(),
  );
  serviceLocator.registerSingleton<CreateOfficeUseCase>(CreateOfficeUseCase());
  serviceLocator.registerSingleton<DownloadWaterUsageReportUseCase>(
    DownloadWaterUsageReportUseCase(),
  );
}
