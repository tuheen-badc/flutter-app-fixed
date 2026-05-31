class ApiUrls {
  static const baseURL = "https://badc-pump-management-smz6yhq6nq-el.a.run.app";
  //static const baseURL = "http://localhost:8080";

  static const register = '$baseURL/api/v1/auth/register';
  static const verifyRegistration = '$baseURL/api/v1/auth/verifyRegistration';
  static const login = '$baseURL/api/v1/auth/authenticate';
  static const forgotPassword = '$baseURL/api/v1/auth/forgotPassword';
  static const resetPassword = '$baseURL/api/v1/auth/resetPassword';
  static const verifyForgotPassword =
      '$baseURL/api/v1/auth/verifyForgotPassword';
  static const loggedInUserInfo = '$baseURL/api/v1/users/me';
  static const allUsers = '$baseURL/api/v1/users';

  static String allPreRegistrations(int officeId) =>
      '$baseURL/api/v1/offices/$officeId/preRegistrations';

  static String createPreRegistrations(int officeId) =>
      '$baseURL/api/v1/offices/$officeId/preRegistrations';

  static String deletePreRegistrations(int officeId, int regId) =>
      '$baseURL/api/v1/$officeId/preRegistrations/$regId';

  static const overallAnalytics = '$baseURL/api/v1/overallAnalytics';
  static const creditInfo = '$baseURL/api/v1/credits';
  static const loggedInUserImage = '$baseURL/api/v1/me/images';
  static const userNameUpdate = '$baseURL/api/v1/users';

  static String updateBlockingStatus(int userId) =>
      '$baseURL/api/v1/users/$userId';

  static const userPasswordUpdate = '$baseURL/api/v1/users';
  static const userPhoneUpdate = '$baseURL/api/v1/users';
  static const verifyPhoneUpdate = '$baseURL/api/v1/users/verifyPhoneUpdate';
  static const uploadProfilePicture = '$baseURL/api/v1/userImages';
  static const creditHistory = '$baseURL/api/v1/creditHistory';
  static const allPumpStationHistory = '$baseURL/api/v1/waterUsagesHistories';
  static const pumpStationBasicList = '$baseURL/api/v1/pumpStations';
  static const allPumpStationList = '$baseURL/api/v1/pumpStations';
  static const pumpStationListPlain = '$baseURL/api/v1/pumpStations/plain';
  static const electricityAvailabilityIndicators =
      '$baseURL/api/v1/electricityAvailabilityIndicators';
  static const divisions = '$baseURL/api/v1/locations/divisions';
  static const districts = '$baseURL/api/v1/locations/districts';
  static const upazillas = '$baseURL/api/v1/locations/upazillas';
  static const unions = '$baseURL/api/v1/locations/unions';
  static const userTiers = '$baseURL/api/v1/userTiers';
  static const waterPricing = '$baseURL/api/v1/waterPricing';
  static const String updateWaterPricing = '$baseURL/api/v1/waterPricing';

  static String pumpExecutionRequest(int pumpStationId) =>
      '$baseURL/api/v1/pumpStations/$pumpStationId/pumpExecutionRequest';

  static String getWaterBudget(int pumpStationId) =>
      '$baseURL/api/v1/pumpStations/$pumpStationId/waterBudgets';

  static String updateWaterBudget(int pumpStationId) =>
      '$baseURL/api/v1/pumpStations/$pumpStationId/waterBudgets';

  static String getAllLandAllocations(int pumpStationId) =>
      '$baseURL/api/v1/pumpStations/$pumpStationId/landAllocations';

  static String createLandAllocation(int pumpStationId) =>
      '$baseURL/api/v1/pumpStations/$pumpStationId/landAllocations';

  static String updateLandAllocation(int pumpStationId, int allocationId) =>
      '$baseURL/api/v1/pumpStations/$pumpStationId/landAllocations/$allocationId';

  static String deleteLandAllocation(int pumpStationId, int allocationId) =>
      '$baseURL/api/v1/pumpStations/$pumpStationId/landAllocations/$allocationId';

  static String singlePumpStationHistory(int pumpStationId) =>
      '$baseURL/api/v1/pumpStations/$pumpStationId/waterUsagesHistories';

  static String userOfPumpStation(int pumpStationId) =>
      '$baseURL/api/v1/pumpStations/$pumpStationId/users';

  static String pumpDetailById(int pumpStationId) =>
      '$baseURL/api/v1/pumpStations/$pumpStationId';

  static String userTierInfo(int userId) =>
      '$baseURL/api/v1/users/$userId/userTiers';

  static String userCreditHistories(int userId) =>
      '$baseURL/api/v1/users/$userId/creditHistories';

  static String userPumpUsagesHistories(int userId) =>
      '$baseURL/api/v1/users/$userId/waterUsagesHistories';

  static String userPumpStationList(int userId) =>
      '$baseURL/api/v1/users/$userId/pumpStations';

  static String userInfoById(int userId) => '$baseURL/api/v1/users/$userId';

  static String userImageById(int userId) =>
      '$baseURL/api/v1/users/$userId/images';

  static const submitComplaint = '$baseURL/api/v1/complaints';
  static const complaints = '$baseURL/api/v1/complaints';

  static String updateComplaint(int complaintId) =>
      '$baseURL/api/v1/complaints/$complaintId';

  static const String firmwareUpload = '$baseURL/api/v1/firmwareFiles/upload';
  static const String firmwareHistory = '$baseURL/api/v1/firmwareFiles';

  static const String allOfficeList = '$baseURL/api/v1/offices';

  static String get officeListPlain => '$baseURL/api/v1/offices/plain';

  static String get createPumpStation => '$baseURL/api/v1/pumpStations';

  static String get createOffice => '$baseURL/api/v1/offices';

  static const String waterUsageReportDownload =
      '$baseURL/api/v1/waterUsagesReport/download';

  static String officeUsers(int officeId) =>
      '$baseURL/api/v1/offices/$officeId/users';

  static String officePumps(int officeId) =>
      '$baseURL/api/v1/offices/$officeId/pumpStations';

  static String officeAnalytics(int officeId) =>
      '$baseURL/api/v1/offices/$officeId/pumpAnalytics';

  static String pumpAnalytics(int pumpStationId) =>
      '$baseURL/api/v1/pumpStations/$pumpStationId/pumpAnalytics';

  static String userSpecificAnalytics(int userId) =>
      '$baseURL/api/v1/users/$userId/pumpAnalytics';

  static String electricityStatusHistory(int pumpStationId) =>
      '$baseURL/api/v1/pumpStations/$pumpStationId/electricityStatusHistories';

  static String pumpLiveStatus(int userId) =>
      '$baseURL/api/v1/users/$userId/pumpLiveStatus';

  static String updateDataProviderPhone(int pumpStationId) =>
      '$baseURL/api/v1/pumpStations/$pumpStationId';

  static String updateManagerPhone(int pumpStationId) =>
      '$baseURL/api/v1/pumpStations/$pumpStationId';

  static String updatePumpLocation(int pumpStationId) =>
      '$baseURL/api/v1/pumpStations/$pumpStationId';

  static String officeDetail(int officeId) =>
      '$baseURL/api/v1/offices/$officeId';

  static String updateOfficeContact(int officeId) =>
      '$baseURL/api/v1/offices/$officeId';

  static String updateOfficeLocation(int officeId) =>
      '$baseURL/api/v1/offices/$officeId';
}
