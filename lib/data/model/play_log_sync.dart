import 'package:hive_flutter/adapters.dart';

import '../usecases/fetch_contents.dart';

class LogSyncRequest {
  final String deviceId;
  final List<PlayLogSync> playLogSyncs;

  const LogSyncRequest({
    required this.deviceId,
    required this.playLogSyncs,
  });

  factory LogSyncRequest.fromJson(Map<String, dynamic> json) {
    return LogSyncRequest(
      deviceId: json['deviceID'],
      playLogSyncs: List<PlayLogSync>.from(json['playLogSyncs'].map((x) => PlayLogSync.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceID': deviceId,
      'logs': playLogSyncs.map((x) => x.toJson()).toList(),
    };
  }
}

class PlayLogSync {
  final String deviceId;
  final String contentId;
  final DateTime playTime;
  final String logId;
  final String logType;

  const PlayLogSync({
    required this.deviceId,
    required this.contentId,
    required this.playTime,
    required this.logId,
    required this.logType,
  });

  factory PlayLogSync.fromJson(Map<String, dynamic> json) {
    return PlayLogSync(
      deviceId: json['deviceID'],
      contentId: json['contentID'],
      playTime: DateTime.parse(json['playTime']),
      logId: json['playlog'],
      logType: json['logType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logData': contentId,
      'loggedAt': playTime.toIso8601String(),
      'logIdentifier': logId,
      'logType': logType,
    };
  }

  PlayLogSyncParam toParam() {
    return PlayLogSyncParam([
      LogSyncRequest(deviceId: deviceId, playLogSyncs: [this])
    ]);
  }

  @override
  String toString() {
    return 'PlayLogSync{deviceId: $deviceId, contentId: $contentId, playTime: $playTime, logId: $logId, logType: $logType}';
  }
}

class PlayLogSyncAdapter extends TypeAdapter<PlayLogSync> {
  @override
  final int typeId = 8;

  @override
  PlayLogSync read(BinaryReader reader) {
    return PlayLogSync(
      deviceId: reader.read(),
      contentId: reader.read(),
      playTime: reader.read(),
      logId: reader.read(),
      logType: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, PlayLogSync obj) {
    writer.write(obj.deviceId);
    writer.write(obj.contentId);
    writer.write(obj.playTime);
    writer.write(obj.logId);
    writer.write(obj.logType);
  }
}
