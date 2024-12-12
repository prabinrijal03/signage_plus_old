import '../../services/hive_services.dart';
import '../model/contents.dart';
import '../model/custom_user.dart';
import '../model/device_layout.dart';
import '../model/devices.dart';
import '../model/scroll_text.dart';
import '../model/ward_details.dart';
import '../model/ward_settings.dart';

abstract class LocalDatasource {
  void setDevice(Device deviceToCache);

  Future<DeviceLayoutInfo> getCachedLayouts();
  void cacheLayoutsInfo(DeviceLayoutInfo layoutsToCache);

  Future<ScrollTexts> getScrollTexts();
  void cacheScrollTexts(ScrollTexts scrollTextsToCache);

  Future<Contents> getCachedContents();
  void cacheContents(Contents contentsToCache);

  // For Custom User
  Future<List<CustomUser>> getCustomUser();
  void cacheCustomUser(List<CustomUser> customUserToCache);

  // Ward Info
  Future<WardDetails> getWardDetails();
  void cacheWardDetails(WardDetails wardInfoToCache);

  // Ward Settings
  Future<WardSettings> getWardSettings();
  void cacheWardSettings(WardSettings wardSettingsToCache);

  // Ward Contents
  Future<List<WardContent>> getWardContents();
  void cacheWardContents(List<WardContent> wardContentsToCache);
}

class LocalDatasourceImpl implements LocalDatasource {
  final HiveService _hiveService;
  const LocalDatasourceImpl(this._hiveService);

  @override
  void setDevice(Device deviceToCache) {
    return _hiveService.addDeviceToBox(deviceToCache);
  }

  @override
  void cacheLayoutsInfo(DeviceLayoutInfo layoutsToCache) {
    return _hiveService.addLayoutsToBox(layoutsToCache);
  }

  @override
  Future<DeviceLayoutInfo> getCachedLayouts() async {
    final layouts = _hiveService.getLayouts();
    try {
      return Future.value(layouts);
    } on Exception {
      throw Exception();
    }
  }

  @override
  Future<ScrollTexts> getScrollTexts() async {
    final jsonString = _hiveService.getActiveScrollingText();
    if (jsonString != null) {
      return Future.value(jsonString);
    } else {
      throw Exception();
    }
  }

  @override
  void cacheScrollTexts(ScrollTexts scrollTextsToCache) {
    return _hiveService.addScrollingTextToBox(scrollTextsToCache);
  }

  @override
  void cacheContents(Contents contentsToCache) {
    return _hiveService.addContentsToBox(contentsToCache);
  }

  @override
  Future<Contents> getCachedContents() async {
    final jsonString = _hiveService.getActiveContents();
    try {
      return Future.value(jsonString);
    } on Exception {
      rethrow;
    }
  }

  // For Custom User
  @override
  Future<List<CustomUser>> getCustomUser() async {
    final jsonString = _hiveService.getCustomUserFromBox();
    try {
      return Future.value(jsonString);
    } on Exception {
      rethrow;
    }
  }

  @override
  void cacheCustomUser(List<CustomUser> customUserToCache) {
    return _hiveService.addCustomUserToBox(customUserToCache);
  }

  // Ward Details
  @override
  Future<WardDetails> getWardDetails() async {
    final wardDetails = _hiveService.getWardDetailsFromBox();
    try {
      return Future.value(wardDetails);
    } on Exception {
      rethrow;
    }
  }

  @override
  void cacheWardDetails(WardDetails wardDetailsToCache) {
    return _hiveService.addWardDetailsToBox(wardDetailsToCache);
  }

  // Ward Settings
  @override
  Future<WardSettings> getWardSettings() async {
    final wardSettings = _hiveService.getWardSettingsFromBox();
    try {
      return Future.value(wardSettings);
    } on Exception {
      rethrow;
    }
  }

  @override
  void cacheWardSettings(WardSettings wardSettingsToCache) {
    return _hiveService.addWardSettingsToBox(wardSettingsToCache);
  }

  // Ward Contents

  @override
  void cacheWardContents(List<WardContent> wardContentsToCache) {
    return _hiveService.addWardContentsToBox(wardContentsToCache);
  }

  @override
  Future<List<WardContent>> getWardContents() async {
    final wardContents = _hiveService.getWardContentsFromBox();
    try {
      return Future.value(wardContents);
    } on Exception {
      rethrow;
    }
  }
}
