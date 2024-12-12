import 'package:flutter/foundation.dart';

import '../core/dependency_injection.dart';
import '../data/model/contents.dart';
import '../data/model/play_log_sync.dart';
import '../data/model/scroll_text.dart';
import '../data/usecases/fetch_contents.dart';
import '../resources/constants.dart';
import 'hive_services.dart';
import 'utils.dart';

class LogService {
  const LogService();

  static void sendContentAcknowledge(Content content, String remarks) {
    final remarksParam = RemarkParams(content.id, AppConstants.deviceId!, content.name,
        HiveService().getStoredDateTime()?.toIso8601String() ?? DateTime.now().toIso8601String(), remarks);
    getInstance<FetchContents>().sendContentRemarks(remarksParam);
  }

  static void sendScrollingTextAcknowledge(ScrollText scrollText, String remarks) {
    final remarksParam = RemarkParams(scrollText.id, AppConstants.deviceId!, scrollText.text,
        HiveService().getStoredDateTime()?.toIso8601String() ?? DateTime.now().toIso8601String(), remarks);
    getInstance<FetchContents>().sendScrollRemarks(remarksParam);
  }

  static Future<void> sendPlayLogSync(Content content) async {
    final deviceId = AppConstants.deviceId!;
    final playTime = HiveService().getStoredDateTime() ?? DateTime.now();
    final logId = Utils.generateLogId(deviceId, content.id, playTime.toIso8601String());

    final PlayLogSync playLogSync =
        PlayLogSync(deviceId: deviceId, contentId: content.id, playTime: playTime, logId: logId, logType: LogSyncConstants.contentType);

    HiveService().addPlayLogSyncToBox(playLogSync);

    final result = await getInstance<FetchContents>().syncPlayLog(playLogSync.toParam());
    result.fold((err) {
      debugPrint(err.message);
    }, (loggedId) {
      HiveService().deletePlayLogSyncsFromBox(deviceId, loggedId);
    });
  }

  static Future<void> sendScrollTextLogSync(ScrollText scrollText) async {
    final deviceId = AppConstants.deviceId!;
    final playTime = HiveService().getStoredDateTime() ?? DateTime.now();
    final logId = Utils.generateLogId(deviceId, scrollText.id, playTime.toIso8601String());

    final PlayLogSync playLogSync =
        PlayLogSync(deviceId: deviceId, contentId: scrollText.id, playTime: playTime, logId: logId, logType: LogSyncConstants.scrollingTextType);

    HiveService().addPlayLogSyncToBox(playLogSync);

    final result = await getInstance<FetchContents>().syncPlayLog(playLogSync.toParam());
    result.fold((err) {
      debugPrint(err.message);
    }, (loggedId) {
      HiveService().deletePlayLogSyncsFromBox(deviceId, loggedId);
    });
  }

  static Future<void> syncLogsFromHive() async {
    final deviceId = AppConstants.deviceId!;
    final playLogSyncs = HiveService().getLogSyncRequests();

    if (playLogSyncs.isEmpty) return;
    final PlayLogSyncParam params = PlayLogSyncParam(playLogSyncs);
    final result = await getInstance<FetchContents>().syncPlayLog(params);
    result.fold((err) {
      debugPrint(err.message);
    }, (loggedId) {
      HiveService().deletePlayLogSyncsFromBox(deviceId, loggedId);
    });
  }
}
