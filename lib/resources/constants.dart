import '../core/dependency_injection.dart';
import '../presentation/homescreen/cubit/layouts/layouts_cubit.dart';
import '../services/hive_services.dart';
// import '../services/utils.dart';

class AppConstants {
  static late double deviceHeight;
  static late double deviceWidth;
  static late ForceOrientation forceOrientation;
  static DateTime get now =>
      HiveService().getStoredDateTime() ?? DateTime.now();
  static DateTime ntpNow = now;
  static const date = 'Mar 19, 2024';
  static const Map<String, String> downloadingList = {};
  static bool? isRooted;

  static bool useServerDateTime = true;

  static setDeviceDimension(double height, double width) {
    deviceHeight = height;
    deviceWidth = width;
  }

  static const String appName = 'Signage Plus';
  static String? get deviceId => getInstance<HiveService>().getDeviceId();
  static const String weatherAPIkey = "6b99178ac1387031c94a0acfe6264e8a";

  static String specificTimeRange = 'Specific Time Range';
  static String dateRangeOnly = 'Date Range Only';

  static String layoutTypeCustom = 'CUSTOM';
  static String layoutTypeWard = 'WARD';
  static String layoutToken = 'TOKEN';
  static String layoutTokenButton = 'TOKEN BUTTON';

  static String emptyScrollText =
      'No scroll text available. Please add scroll text from the dashboard.';

  static const connectionTimeOutSeconds = 300;
}

class UrlConstants {
  static const baseUrl = 'https://api.signageplus.net';
  static const tokenBaseUrl = 'http://192.168.1.14:8086';
  // static const baseUrl = "http://192.168.0.145:8000";
  // static const baseUrl = 'http://172.16.5.227:8000';
  static const tokenSocketUrl = 'http://192.168.1.14:8088';
  // static const tokenSocketUrl = "http://192.168.0.145:5000";
  // static const timeServerUrl = 'http://192.168.10.8';
  static const timeServerUrl = null;
  // static const baseUrl = 'http://192.168.0.252:8000';
  // static const tokenSocketUrl = 'http://192.168.0.252:5000';
  // static const baseUrl = 'http://192.168.0.128:8000';
  // static const tokenSocketUrl = 'http://192.168.0.112:5000';
  static const version = '/api/v1';

  // static String versionUrl = Utils.getVersionUrl();
  static String versionUrl = '$baseUrl$version';
  static const tokenVersionUrl = '$tokenSocketUrl$version';
  static const tokenBaseVersionUrl = '$tokenBaseUrl$version';

  static String serverDateTime = '$versionUrl/time';

  static String authUrl = '$versionUrl/auth';

  static String content = '$versionUrl/contents';

  static String clientUrl = '$authUrl/client';

  static String login = '$clientUrl/login/token';
  static String assignDevice = '$versionUrl/devices/';

  static String deviceLayout = '$versionUrl/deviceLayouts/device/';

  static String scrollTexts = '$versionUrl/scroll/device/';
  static String contents = '$content/device/';
  static String contentRemarks = '$content/remarks/';
  static String forex = '$versionUrl/devices/forex/';
  static String contentUrls =
      '$versionUrl/devices/${AppConstants.deviceId}/content-urls';
  static String playLogSync = '$versionUrl/logs';
  static String scrollTextRemarks = '$versionUrl/scroll/remarks/';
  static String screenshot = '$versionUrl/temp';
  static String wardDetails = '$versionUrl/wards/details';
  static String wardSettings = '$versionUrl/wards/setting';
  static String setVersion = '$versionUrl/version/device';
  static String checkDeviceId = '$versionUrl/devices/check';

  // For Custom User
  static String customUser = '$versionUrl/customusers';
  static String condition = '$customUser/conditions/';

  // For Token Display
  static String getCounters = "$tokenBaseVersionUrl/tokens?progress=true";
  static String getIssuers =
      "$tokenVersionUrl/counter/issuer/device/${AppConstants.deviceId}";
  static String getCounterCount(String id) =>
      "$tokenVersionUrl/counter/issuer/count/$id";

  static String getFeedbackQuestions =
      "$tokenVersionUrl/feedback/questions/${HiveService().getOrganizationId()}";
  static String postFeedback = "$tokenVersionUrl/feedback";

  static String generateToken = "/tokens/generate";
}

class RemarkConstants {
  static const String firstDownload = 'First Download';
  static const String alreadyExists = 'File Already Exists';

  static const String addedToContentBox = 'Content Added to Content Box';
  static const String updatedContent = "Content Updated";
  static const String deletedContent = "Content Deleted";

  static const String addedScrollTextToScrollTextBox =
      'Scroll Text Added to Scroll Text Box';
  static const String updatedScrollText = "Scroll Text Updated";

  static const String deletedScrollText = "Scroll Text Deleted";
}

class LogSyncConstants {
  static const contentType = "content";
  static const scrollingTextType = "scroll";
}
