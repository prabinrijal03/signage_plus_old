import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'utils.dart';
import '../data/model/ward_details.dart';
import '../data/model/contents.dart';
import '../data/model/custom_user.dart';
import '../data/model/ward_settings.dart';
import '../resources/constants.dart';
import 'log_services.dart';

import '../data/model/device_layout.dart';
import '../data/model/devices.dart';
import '../data/model/play_log_sync.dart';
import '../data/model/scroll_text.dart';

class HiveService {
  static late final Directory dir;

  static Future<void> init() async {
    dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter();

    Hive.registerAdapter(DeviceAdapter());
    Hive.registerAdapter(ScrollTextsAdapter());
    Hive.registerAdapter(ScrollTextAdapter());
    Hive.registerAdapter(ScrollCategoryAdapter());
    Hive.registerAdapter(ScrollTimerAdapter());
    Hive.registerAdapter(TimeOfDayAdapter());
    Hive.registerAdapter(PlayLogSyncAdapter());
    Hive.registerAdapter(WardInfoAdapter());
    Hive.registerAdapter(WardNewsAdapter());
    Hive.registerAdapter(WardPersonnelAdapter());
    Hive.registerAdapter(WardDetailsAdapter());
    Hive.registerAdapter(WardSettingsAdapater());

    await Hive.openBox<Device>(device);
    await Hive.openBox<String>(dateTime);
    await Hive.openBox<String>(deviceExtras);
    await Hive.openBox<ScrollTexts>(scrollingTexts);
    await Hive.openBox<String>(layout);
    await Hive.openBox<String>(contents);
    final toRemove = await Hive.openBox<List<PlayLogSync>>(playLogSync);
    toRemove.clear();
    await Hive.openBox<String>(customUser);
    await Hive.openBox<WardDetails>(wardDetails);
    await Hive.openBox<WardSettings>(wardSettings);
    await Hive.openBox<String>(wardContent);
    await Hive.openBox<String>(forcePlayStatus);
  }

  static Future<void> clear() async {
    Hive.close();
    await Future.wait(
      [
        Hive.deleteBoxFromDisk(contents),
        Hive.deleteBoxFromDisk(scrollingTexts),
        Hive.deleteBoxFromDisk(layout),
        Hive.deleteBoxFromDisk(customUser),
        Hive.deleteBoxFromDisk(wardDetails),
        Hive.deleteBoxFromDisk(wardSettings),
        Hive.deleteBoxFromDisk(wardContent),
        Hive.deleteBoxFromDisk(forcePlayStatus),
      ],
    );
  }

  // ------------ Device ------------
  static String device = 'device';
  static Box<Device> deviceBox = Hive.box<Device>(device);

  void addDeviceToBox(Device device) {
    deviceBox.put("device", device);
  }

  Device getDeviceFromBox() {
    return deviceBox.get("device")!;
  }

  String? getDeviceId() {
    return deviceBox.get("device")?.id;
  }

  void removeDeviceFromBox() {
    deviceBox.delete("device");
  }

// ---------------- DateTime --------------
  static String dateTime = 'dateTime';
  static Box<String> dateTimeBox = Hive.box<String>(dateTime);

  void addDateTimeToBox(DateTime dateTime) {
    dateTimeBox.put("dateTime", dateTime.toString());
  }

  void incrementStoredDateTime() {
    final dateTime = getStoredDateTime();
    if (dateTime != null) {
      final newDt = dateTime.add(const Duration(seconds: 1));
      AppConstants.ntpNow = newDt;
      addDateTimeToBox(newDt);
    }
  }

  DateTime? getStoredDateTime() {
    return dateTimeBox.get("dateTime") != null
        ? DateTime.parse(dateTimeBox.get("dateTime")!.replaceAll("+0545", "Z"))
        : null;
  }

// ------------ Device Extras ------------
  static String deviceExtras = 'deviceExtras';
  static Box<String> deviceExtrasBox = Hive.box<String>(deviceExtras);

  void addAccessTokenToBox(String accessToken) {
    deviceExtrasBox.put("accessToken", accessToken);
  }

  String? getAccessToken() {
    return deviceExtrasBox.get("accessToken");
  }

  String? getOrganizationId() {
    return deviceExtrasBox.get("orgId");
  }

  void addOrganizationIdToBox(String orgId) {
    deviceExtrasBox.put("orgId", orgId);
  }

  void addCurrentVersionIdToBox(String currentVersionId) {
    deviceExtrasBox.put("currentVersionId", currentVersionId);
  }

  String? getCurrentVersionId() {
    return deviceExtrasBox.get("currentVersionId");
  }

  void addPaddingToBox(String padding) {
    deviceExtrasBox.put("padding", padding);
  }

  String? getPadding() {
    return deviceExtrasBox.get("padding");
  }

  void addStopDurationToBox(String stopDuration) {
    deviceExtrasBox.put("stopDuration", stopDuration);
  }

  String? getStopDuration() {
    return deviceExtrasBox.get("stopDuration");
  }

  void addOrientationToBox(String orientation) {
    deviceExtrasBox.put("orientation", orientation);
  }

  String getOrientation() {
    return deviceExtrasBox.get("orientation") ?? "LEFT";
  }

  static void addDefaultPrinter(String mac) {
    deviceExtrasBox.put("defaultPrinter", mac);
  }

  static String? getDefaultPrinter() {
    return deviceExtrasBox.get("defaultPrinter");
  }

  static void addVolume(int? volume) {
    if (volume == null) return;
    deviceExtrasBox.put("volume", volume.toString());
  }

  static int getVolume() {
    return int.parse(deviceExtrasBox.get("volume") ?? "100");
  }

  static void addTokenDeviceCode(String tokenDisplay) {
    deviceExtrasBox.put("tokenDeviceCode", tokenDisplay);
  }

  static String? getTokenDeviceCode() {
    return deviceExtrasBox.get("tokenDeviceCode");
  }

  // ------------ Layouts ------------
  static String layout = 'layout';
  static Box<String> layoutsBox = Hive.box<String>(layout);

  void addLayoutsToBox(DeviceLayoutInfo layout) {
    layoutsBox.put("deviceLayout", layout.toString());
  }

  DeviceLayoutInfo? getLayouts() {
    final layout = layoutsBox.get("deviceLayout");
    if (layout != null) {
      return DeviceLayoutInfo.fromJson(jsonDecode(layout));
    } else {
      return null;
    }
  }

  // ------------ Scrolling Text ------------
  static String scrollingTexts = 'scrollingText';
  static Box<ScrollTexts> scrollingTextsBox =
      Hive.box<ScrollTexts>(scrollingTexts);

  void addScrollingTextToBox(ScrollTexts scrollTexts) {
    scrollingTextsBox.put("scrollTexts", scrollTexts);
  }

  void appendScrollingTextToBox(List<ScrollText> scrollTexts,
      {bool isUpdate = false}) {
    // append content to box
    final scrollingTexts = getAllScrollingText();
    if (scrollingTexts != null) {
      scrollingTexts.scrollTexts.addAll(scrollTexts);
      scrollingTextsBox.put("scrollTexts", scrollingTexts);
    } else {
      scrollingTextsBox.put(
          "scrollTexts", ScrollTexts(scrollTexts: scrollTexts));
    }

    // return if content is updated to avoid logging twice
    if (isUpdate) return;
    // send content added log
    LogService.sendScrollingTextAcknowledge(
        scrollTexts.first, RemarkConstants.addedScrollTextToScrollTextBox);
  }

  void deleteScrollingTextFromBox(String id, {bool isUpdate = false}) {
    ScrollText? scrollTextToBeDeleted;
    // delete scrolling text from active scrolling texts
    ScrollTexts? scrollTexts = scrollingTextsBox.get("scrollTexts");
    if (scrollTexts != null) {
      scrollTextToBeDeleted = scrollTexts.scrollTexts
          .firstWhereOrNull((content) => content.id == id);
      scrollTexts.scrollTexts.remove(scrollTextToBeDeleted);
      scrollingTextsBox.put("scrollTexts", scrollTexts);
    }
    // return if scroll text is updated to avoid logging twice
    if (isUpdate) return;
    // send content deleted log
    if (scrollTextToBeDeleted != null) {
      LogService.sendScrollingTextAcknowledge(
          scrollTextToBeDeleted, RemarkConstants.deletedScrollText);
    }
  }

  void updateScrollingTextFromBox(ScrollText scrollText) {
    deleteScrollingTextFromBox(scrollText.id, isUpdate: true);
    appendScrollingTextToBox([scrollText], isUpdate: true);
    // send scrolltext updated log
    LogService.sendScrollingTextAcknowledge(
        scrollText, RemarkConstants.updatedScrollText);
  }

  ScrollTexts? getAllScrollingText() {
    return scrollingTextsBox.get("scrollTexts");
  }

  ScrollTexts? getActiveScrollingText() {
    final scrollTexts = scrollingTextsBox.get("scrollTexts");
    if (scrollTexts == null) return null;
    final activeScrollTexts = scrollTexts.scrollTexts
        .where((scrollText) => Utils.isScrollTextActive(scrollText))
        .toList();
    if (activeScrollTexts.isEmpty) return null;
    return ScrollTexts(scrollTexts: activeScrollTexts);
  }

  ScrollTexts? getInactiveScrollingText() {
    final scrollTexts = scrollingTextsBox.get("scrollTexts");
    if (scrollTexts == null) return null;
    final inactiveScrollTexts = scrollTexts.scrollTexts
        .where((scrollText) => !Utils.isScrollTextActive(scrollText))
        .toList();
    if (inactiveScrollTexts.isEmpty) return null;
    return ScrollTexts(scrollTexts: inactiveScrollTexts);
  }

  // ------------ Content Layout ------------
  static String contents = 'contents';
  static Box<String> contentsBox = Hive.box<String>(contents);

  void addContentsToBox(Contents contents) {
    contentsBox.put("contents", contents.toString());
  }

  Future<void> appendContentsToBox(Content content,
      {bool isUpdate = false}) async {
    // append content to box
    final contents = getAllContents();
    if (contents != null) {
      contents.contents.add(content);
      contentsBox.put("contents", contents.toString());
    } else {
      contentsBox.put("contents", Contents(contents: [content]).toString());
    }
    if (isUpdate) return;
    // send content added log
    LogService.sendContentAcknowledge(
        content, RemarkConstants.addedToContentBox);
  }

  void updateContentInBox(Content content) {
    deleteContentFromBox(content.id, isUpdate: true);
    appendContentsToBox(content, isUpdate: true);
    // send content updated log
    LogService.sendContentAcknowledge(content, RemarkConstants.updatedContent);
  }

  void deleteContentFromBox(String id, {bool isUpdate = false}) {
    // content to be deleted variable to store content to be deleted for logging
    Content? contentToBeDeleted;
    // delete content from active contents
    final Contents? contents = getAllContents();
    if (contents != null) {
      contentToBeDeleted =
          contents.contents.firstWhereOrNull((content) => content.id == id);

      contents.contents.remove(contentToBeDeleted);
      contentsBox.put('contents', contents.toString());
    }

    // return if content is updated to avoid logging twice
    if (isUpdate) return;
    // send content deleted log
    if (contentToBeDeleted != null) {
      LogService.sendContentAcknowledge(
          contentToBeDeleted, RemarkConstants.deletedContent);
    }
  }

  Contents? getAllContents() {
    final contents = contentsBox.get("contents");
    if (contents == null) return null;
    final contentsList =
        Contents.fromJson(jsonDecode(contents)['content']).contents;
    return Contents(contents: contentsList);
  }

  Contents? getActiveContents() {
    // get active contents
    final contents = contentsBox.get("contents");
    if (contents == null) return null;
    final contentsList =
        Contents.fromJson(jsonDecode(contents)['content']).contents;
    final activeContents = contentsList
        .where((content) => Utils.isContentActive(content))
        .toList();
    if (activeContents.isEmpty) return null;
    return Contents(contents: activeContents);
  }

  Contents? getInactiveContents() {
    // get inactive contents
    final contents = contentsBox.get("contents");
    if (contents == null) return null;
    final contentsList =
        Contents.fromJson(jsonDecode(contents)['content']).contents;
    final inactiveContents = contentsList
        .where((content) => !Utils.isContentActive(content))
        .toList();
    if (inactiveContents.isEmpty) return null;
    return Contents(contents: inactiveContents);
  }

  // --------- Play Log Sync ---------

  static String playLogSync = 'playLogSync';
  static Box<List<PlayLogSync>> playLogSyncBox =
      Hive.box<List<PlayLogSync>>(playLogSync);

  void addPlayLogSyncToBox(PlayLogSync playLogSync) {
    List<PlayLogSync> playLogSyncs =
        getAllPlayLogSyncFromBox(playLogSync.deviceId);
    playLogSyncs.add(playLogSync);
    playLogSyncBox.put(playLogSync.deviceId, playLogSyncs);
  }

  List<PlayLogSync> getAllPlayLogSyncFromBox(String deviceId) {
    final playLogSyncs = playLogSyncBox.get(deviceId);
    if (playLogSyncs != null) {
      return playLogSyncs;
    } else {
      return [];
    }
  }

  List<LogSyncRequest> getLogSyncRequests() {
    final List<LogSyncRequest> playLogSyncs = [];

    void toRequest(deviceId) {
      playLogSyncs.add(
        LogSyncRequest(
          deviceId: deviceId,
          playLogSyncs: playLogSyncBox.get(deviceId)!,
        ),
      );
    }

    playLogSyncBox.keys.forEach(toRequest);

    return playLogSyncs;
  }

  void deletePlayLogSyncFromBox(String deviceId, String logId) {
    final playLogSyncs = getAllPlayLogSyncFromBox(deviceId);
    playLogSyncs.removeWhere((element) => element.logId == logId);
    playLogSyncBox.put(deviceId, playLogSyncs);
  }

  void deletePlayLogSyncsFromBox(String deviceId, List<String> logIds) {
    for (String logId in logIds) {
      final playLogSyncs = getAllPlayLogSyncFromBox(deviceId);
      playLogSyncs.removeWhere((element) => element.logId == logId);
      playLogSyncBox.put(deviceId, playLogSyncs);
    }
  }

  // --------- Custom User ---------
  static String customUser = 'customUser';
  static Box<String> customUserBox = Hive.box<String>(customUser);

  void addCustomUserToBox(List<CustomUser> customUsers) {
    customUserBox.put("customUser", jsonEncode(customUsers));
  }

  List<CustomUser> getCustomUserFromBox() {
    final jsonString = customUserBox.get("customUser");
    if (jsonString != null) {
      return (jsonDecode(jsonString) as List)
          .map((e) => CustomUser.fromJson(e))
          .toList();
    } else {
      throw Exception();
    }
  }

  // --------- Ward Details ---------
  static String wardDetails = 'wardDetails';
  static Box<WardDetails> wardDetailsBox = Hive.box<WardDetails>(wardDetails);

  void addWardDetailsToBox(WardDetails wardDetails) {
    wardDetailsBox.put("wardDetails", wardDetails);
  }

  WardDetails getWardDetailsFromBox() {
    final wardDetails = wardDetailsBox.get("wardDetails");
    if (wardDetails != null) {
      return wardDetails;
    } else {
      throw Exception();
    }
  }

  // --------- Ward Settings ---------
  static String wardSettings = 'wardSettings';
  static Box<WardSettings> wardSettingsBox =
      Hive.box<WardSettings>(wardSettings);

  void addWardSettingsToBox(WardSettings wardSettings) {
    wardSettingsBox.put("wardSettings", wardSettings);
  }

  WardSettings getWardSettingsFromBox() {
    final wardSettings = wardSettingsBox.get("wardSettings");
    if (wardSettings != null) {
      return wardSettings;
    } else {
      throw Exception();
    }
  }

// ------------ Ward Content ------------
  static String wardContent = 'wardContent';
  static Box<String> wardContentBox = Hive.box<String>(wardContent);

  void addWardContentsToBox(List<WardContent> wardContent) {
    final wardContents = getWardContentsFromBox();
    if (wardContents == null || wardContents.isEmpty) {
      wardContentBox.put("wardContent", jsonEncode(wardContent));
    } else {
      wardContents.addAll(wardContent);
      wardContentBox.put("wardContent", jsonEncode(wardContent));
    }
  }

  void addWardContentToBox(WardContent wardContent) {
    final wardContents = getWardContentsFromBox();
    if (wardContents == null || wardContents.isEmpty) {
      wardContentBox.put("wardContent", jsonEncode([wardContent]));
    } else {
      wardContents.add(wardContent);
      wardContentBox.put("wardContent", jsonEncode(wardContents));
    }
  }

  List<WardContent>? getWardContentsFromBox() {
    final wardContent = wardContentBox.get("wardContent");
    if (wardContent != null) {
      return (jsonDecode(wardContent) as List)
          .map((e) => WardContent.fromJson(e))
          .toList();
    }
    return null;
  }

  void deleteWardContentFromBox(String id) {
    final wardContents = getWardContentsFromBox();
    if (wardContents == null || wardContents.isEmpty) return;
    wardContents.removeWhere((element) => element.id == id);
    wardContentBox.put("wardContent", jsonEncode(wardContents));
  }

  void updateWardContentInBox(List<WardContent> wardContent) {
    final wardContents = getWardContentsFromBox();
    if (wardContents == null || wardContents.isEmpty) return;
    wardContents.removeWhere((element) => element.id == wardContent.first.id);
    wardContents.addAll(wardContent);
    wardContentBox.put("wardContent", jsonEncode(wardContents));
  }

// ------------ Ward Content ------------
  static String forcePlayStatus = 'forcePlayStatus';
  static Box<String> forcePlayEnabledBox = Hive.box<String>(forcePlayStatus);
  void savedForcePlayStatus( bool status) {
    forcePlayEnabledBox.put(forcePlayStatus, status.toString());
  }

  bool getForcePlayStatus() {
    return forcePlayEnabledBox.get(forcePlayStatus) == "true";
  }
}
