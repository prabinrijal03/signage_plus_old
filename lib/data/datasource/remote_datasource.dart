import 'package:dio/dio.dart';
import 'package:slashplus/core/extensions.dart';
import 'package:slashplus/data/model/user_information.dart';

import '../../resources/constants.dart';
import '../../services/hive_services.dart';
import '../model/contents.dart';
import '../model/custom_user.dart';
import '../model/device_layout.dart';
import '../model/devices.dart';
import '../model/feedback_questions.dart';
import '../model/play_log_sync.dart';
import '../model/scroll_text.dart';
import '../model/token.dart';
import '../model/ward_details.dart';
import '../model/ward_settings.dart';

abstract class RemoteDatasource {
  Future<DateTime> getServerDateTime();
  Future<Devices> login(String code);
  Future<bool> assignDevice(String deviceId);
  Future<bool> checkDeviceId(String deviceId);
  Future<DeviceLayoutInfo> getDeviceLayout(String deviceId);
  Future<ScrollTexts> getScrollTexts();
  Future<Contents> getContents();
  Future<void> download(String url, String path);
  Future<bool> forcePLayEnabled(String deviceId);
  Future<void> contentsForcePlay(String orgId, String contentId);
  Future<ContentUrls> getContentUrls();
  Future<void> sendContentRemarks(String contentId, String deviceId, String url,
      String savedAt, String remark);
  Future<void> sendScrollRemarks(String contentId, String deviceId, String url,
      String savedAt, String remark);
  Future<List<String>> syncPlayLog(List<LogSyncRequest> playLogSyncs);
  Future<String> sendScreenshot(String imageData);
  Future<String> setVersion(String deviceId, String versionId);

  // Token Feedback
  Future<FeedbackQuestions> getFeedbackQuestions();
  Future<String> postFeedback(Map<String, dynamic> feedback);

  // For Custom User
  Future<List<CustomUser>> getCustomUser(String deviceId);
  Future<List<Condition>> getCondition(String deviceId);

  // Ward
  Future<WardDetails> getWardDetails();
  Future<WardSettings> getWardSettings();

  // Token System
  Future<Token> generateToken(ApplicantInfoRequest userInfo);
}

class RemoteDatasourceImpl implements RemoteDatasource {
  final Dio _dio;
  final Dio _counterDio;

  RemoteDatasourceImpl(this._dio, this._counterDio);

  @override
  Future<DateTime> getServerDateTime() async {
    try {
      final response = await _dio.get(UrlConstants.serverDateTime);
      return (response.data['time'] as String)
          .toDateTime('MM/dd/yyyy, hh:mm:ss a');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Devices> login(String code) async {
    try {
      final response = await _dio.post(
        UrlConstants.login,
        data: {'code': code},
      );
      final orgId = response.data['data']['orgId'] as String?;
      if (orgId != null) {
        HiveService().addOrganizationIdToBox(orgId);
      }
      HiveService().addAccessTokenToBox(response.data['data']['accessToken']);
      return Devices.fromJson(response.data['data']['devices']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> forcePLayEnabled(String deviceId) async {
    try {
      final response = await _dio.get(
          UrlConstants.forcePlayEnabled.replaceFirst(':deviceId', deviceId));
      if (response.statusCode == 200) {
        print("Response Message: ${response.data['message']}");
        print("Data: ${response.data['data']}");
        return true;
      } else {
        print("Error: ${response.statusCode}");
        return false;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("Error Response: ${e.response?.data}");
      } else {
        print("Error Message: ${e.message}");
      }
      return false;
    }
  }

  @override
Future<dynamic> contentsForcePlay(String orgId, String contentId) async {
  try {
    final response = await _dio.post(
      UrlConstants.forcePlayEnabledContent,
      data: {
        "orgId": orgId,
        "contentId": contentId,
      },
    );

    print('Full response data: ${response.data}');

   
    if (response.data != null && response.data is Map<String, dynamic>) {
      final responseData = response.data;

      if (responseData.containsKey('data')) {
        return responseData['data'];
      } else if (responseData.containsKey('message')) {
        return responseData['message'];
      } else {
        throw Exception('Unexpected response format: ${responseData}');
      }
    } else {
      throw Exception('Response is not a JSON object: ${response.data}');
    }
  } catch (e) {
    print('Error in contentsForcePlay: $e');
    rethrow;
  }
}


  @override
  Future<bool> assignDevice(String deviceId) async {
    try {
      final response =
          await _dio.post("${UrlConstants.assignDevice}$deviceId/assign");
      return response.data['assigned'] as bool;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> checkDeviceId(String deviceId) async {
    try {
      final response =
          await _dio.get("${UrlConstants.checkDeviceId}/$deviceId");
      return response.data['exists'] as bool;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DeviceLayoutInfo> getDeviceLayout(String deviceId) async {
    try {
      final response = await _dio.get("${UrlConstants.deviceLayout}$deviceId");
      return DeviceLayoutInfo.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ScrollTexts> getScrollTexts() async {
    try {
      final response =
          await _dio.get("${UrlConstants.scrollTexts}${AppConstants.deviceId}");
      return ScrollTexts.fromJson(response.data["scrollTexts"]);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Contents> getContents() async {
    try {
      final response =
          await _dio.get("${UrlConstants.contents}${AppConstants.deviceId}");
      return Contents.fromJson(response.data["contents"]);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> download(String url, String path) async {
    print("Downloading video! $url ");
    // final fileName = path.split('/').last;
    try {
      await _dio.download(url, path);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ContentUrls> getContentUrls() async {
    try {
      final response = await _dio.get(UrlConstants.contentUrls);
      return ContentUrls.fromJson(response.data["data"]);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendContentRemarks(String contentId, String deviceId, String url,
      String savedAt, String remark) async {
    try {
      await _dio.post(UrlConstants.contentRemarks, data: {
        "contentID": contentId,
        "deviceID": deviceId,
        "url": url,
        "savedAt": savedAt,
        "remark": remark,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendScrollRemarks(String contentId, String deviceId, String url,
      String savedAt, String remark) async {
    try {
      await _dio.post(UrlConstants.scrollTextRemarks, data: {
        "scrollID": contentId,
        "deviceID": deviceId,
        "scrollText": url,
        "savedAt": savedAt,
        "scrollRemark": remark,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<String>> syncPlayLog(List<LogSyncRequest> playlogsSync) async {
    try {
      await _dio.post(UrlConstants.playLogSync,
          data: playlogsSync.map((e) => e.toJson()).toList());
      return [];
    } catch (e) {
      rethrow;
    }

    // final contents = playLogSyncs.where((element) => element.logType == LogSyncConstants.contentType).toList();
    // final scrollTexts = playLogSyncs.where((element) => element.logType == LogSyncConstants.scrollingTextType).toList();

    // try {
    //   final responses = <Future<Response>>[];

    //   if (contents.isNotEmpty) {
    //     responses.add(_dio.post(
    //       UrlConstants.contentPlayLogSync,
    //       data: contents.map((e) => e.toJson()).toList(),
    //     ));
    //   }

    //   if (scrollTexts.isNotEmpty) {
    //     responses.add(_dio.post(
    //       UrlConstants.scrollTextPlayLogSync,
    //       data: scrollTexts.map((e) => e.toJson()).toList(),
    //     ));
    //   }

    //   final responseList = await Future.wait(responses);

    //   final result = <String>[];

    //   for (final response in responseList) {
    //     if (response.data != null && response.data['data'] != null) {
    //       result.addAll((response.data['data'] as List<dynamic>).cast<String>());
    //     }
    //   }

    //   return result;
    // } catch (e) {
    //   rethrow;
    // }
  }

  @override
  Future<String> sendScreenshot(String imageData) async {
    try {
      final res = await _dio.post(
        UrlConstants.screenshot,
        data: {"image": "data:image/png;base64,$imageData"},
      );
      return res.data['id'];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> setVersion(String deviceId, String versionId) async {
    try {
      final response = await _dio.put(
        UrlConstants.setVersion,
        data: {"deviceID": deviceId, "versionID": versionId},
      );
      return response.data['data']['versionID'];
    } catch (e) {
      rethrow;
    }
  }

  // For Custom User
  @override
  Future<List<CustomUser>> getCustomUser(String deviceId) async {
    try {
      final response = await _dio.get("${UrlConstants.customUser}/$deviceId");
      return (response.data['data'] as List<dynamic>)
          .map((e) => CustomUser.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Condition>> getCondition(String deviceId) async {
    try {
      final response = await _dio.get("${UrlConstants.condition}$deviceId");
      return (response.data['data'] as List<dynamic>)
          .map((e) => Condition.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Ward
  @override
  Future<WardDetails> getWardDetails() async {
    try {
      final response = await _dio.get(UrlConstants.wardDetails);
      return WardDetails.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WardSettings> getWardSettings() async {
    try {
      final response = await _dio.get(UrlConstants.wardSettings);
      return WardSettings.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Token Feedback
  @override
  Future<FeedbackQuestions> getFeedbackQuestions() async {
    try {
      final response = await _dio.get(UrlConstants.getFeedbackQuestions);
      return FeedbackQuestions.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> postFeedback(Map<String, dynamic> feedback) async {
    try {
      final response =
          await _dio.post(UrlConstants.postFeedback, data: feedback);
      return response.data['data']['tokenNumber'];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Token> generateToken(ApplicantInfoRequest userInfo) async {
    try {
      final response =
          await _counterDio.post(UrlConstants.generateToken, data: userInfo);
      return Token.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }
}
