import 'package:ustachi/core/utils/constants/dot_env_variables.dart';

class ApiUrls {
  static const String baseUrl = String.fromEnvironment(
    DotEnvVariables.apiBaseUrl,
    defaultValue: 'https://usta-top.simpl.uz',
  );
  static const String socketBaseUrl = String.fromEnvironment(
    DotEnvVariables.socketBaseUrl,
    defaultValue: 'https://usta-top.simpl.uz',
  );

  static const String api = "/api";
  static const String apiV1 = "$api/v1";
  static const String client = "$apiV1/client";

  static const String master = "$apiV1/master";
  static const String masterAuth = "$master/auth";

  static const String appVersion = "$master/app-version/";

  static const String masterSendCode = "$masterAuth/send-code/";

  static const String masterVerifyCode = "$masterAuth/verify-code/";
  static const String masterLogout = "$masterAuth/logout/";
  static const String masterRefreshToken = "$masterAuth/token/refresh/";
  static const String masterMe = "$masterAuth/me/";

  static const String masterTelegramExchange = "$masterAuth/telegram/exchange/";

  static const String masterDeviceRegister = "$masterAuth/devices/";
  static const String masterDeviceUnregister = "$masterAuth/devices/delete/";

  static const String ordersBase = master;

  static const String orders = "$ordersBase/orders/";
  static const String ordersFeed = "${orders}feed/";
  static const String chatThreads = "$ordersBase/chat/threads/";
  static const String notifications = "$ordersBase/notifications/";
  static const String notificationsReadAll = "${notifications}read-all/";

  static String orderDetail(int id) => "$orders$id/";
  static String orderCancel(int id) => "$orders$id/cancel/";
  static String orderResponses(int id) => "$orders$id/responses/";
  static String orderChoose(int id, int responseId) =>
      "$orders$id/responses/$responseId/choose/";
  static String orderReview(int id) => "$orders$id/review/";
  static String orderRespond(int id) => "$orders$id/respond/";
  static String orderWithdraw(int id) => "$orders$id/withdraw/";
  static String orderInvite(int id) => "$orders$id/invite/";
  static String orderPublish(int id) => "$orders$id/publish/";
  static String orderDecline(int id) => "$orders$id/decline/";
  static String orderAdvance(int id) => "$orders$id/advance/";
  static String chatMessages(int threadId) => "$chatThreads$threadId/messages/";
  static const String mastersList = "$ordersBase/masters/";
  static String masterPublicProfile(int id) => "$ordersBase/masters/$id/";

  static String notificationRead(int id) => "$notifications$id/read/";

  static const String myOrders = "$master/my-orders/";

  static String myOrderDetail(int id) => "$myOrders$id/";
  static String myOrderStatus(int id) => "$myOrders$id/status/";

  static const String locationsRegions = "$api/locations/regions";
  static const String locationsDistricts = "$api/locations/districts";

  static const String masterSpecialties = "$masterAuth/specialties/";
  static const String masterProfile = "$masterAuth/profile/";
  static const String masterProfileRates = "${masterProfile}rates/";
  static const String masterProfileNotes = "${masterProfile}notes/";
  static const String masterWorkSamples = "$masterAuth/profile/work-samples/";
}
