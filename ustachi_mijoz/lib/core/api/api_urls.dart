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
  static const String clientAuth = "$client/auth";

  static const String appVersion = "$client/app-version/";

  static const String clientSendCode = "$clientAuth/send-code/";

  static const String clientVerifyCode = "$clientAuth/verify-code/";

  static const String clientTelegramExchange = "$clientAuth/telegram/exchange/";
  static const String clientLogout = "$clientAuth/logout/";
  static const String clientRefreshToken = "$clientAuth/token/refresh/";
  static const String clientMe = "$clientAuth/me/";

  static const String clientDeviceRegister = "$clientAuth/devices/";
  static const String clientDeviceUnregister = "$clientAuth/devices/delete/";

  static const String ordersBase = client;

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

  static const String specialties = "$ordersBase/specialties/";
  static String masterPublicProfile(int id) => "$ordersBase/masters/$id/";

  static String notificationRead(int id) => "$notifications$id/read/";

  static const String locationsRegions = "$api/locations/regions";
  static const String locationsDistricts = "$api/locations/districts";

  static const String auth = "$api/auth";
  static const String register = "$auth/register/";
  static const String registerPhone = "$register/phone/";
  static const String authVerifyOtp = "$register/verify-otp/";
  static const String loginPhone = "/$auth/login/phone/";
  static const String authResetPassword = "$auth/reset-password/";
  static const String authResetPasswordRequest = "$authResetPassword/request/";
  static const String authResetPasswordVerifyOtp =
      "$authResetPassword/verify-otp/";
  static const String setPassword = "/api/auth/login/set-password/";

  static const String authLogin = "$auth/login/";
  static const String authLoginPhone = '/api/auth/login/phone/';
  static const String authLoginVerifyOtp = "$auth/login/verify-otp/";
  static const String authRegisterVerifyOtp = "$auth/register/verify-otp/";

  static const String authMe = "$auth/me/";

  static const String authRefreshToken = "$auth/refresh-token/";
}
