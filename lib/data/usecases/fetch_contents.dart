import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecase.dart';
import '../model/contents.dart';
import '../model/play_log_sync.dart';
import '../repositories/repository.dart';

class FetchContents implements UseCase<Contents, Params> {
  final Repository _repository;

  FetchContents(this._repository);

  @override
  Future<Either<Failure, Contents>> call(Params params) async {
    return await _repository.getContents();
  }

  Future<Either<Failure, ContentUrls>> fetchUrls(Params params) async {
    return await _repository.getContentUrls();
  }

  Future<Either<Failure, void>> sendContentRemarks(RemarkParams params) async {
    return await _repository.sendContentRemarks(
      params.contentId,
      params.deviceId,
      params.url,
      params.savedAt,
      params.remark,
    );
  }

  Future<Either<Failure, void>> sendScrollRemarks(RemarkParams params) async {
    return await _repository.sendScrollRemarks(
      params.contentId,
      params.deviceId,
      params.url,
      params.savedAt,
      params.remark,
    );
  }

  Future<Either<Failure, List<String>>> syncPlayLog(
      PlayLogSyncParam params) async {
    return await _repository.syncPlayLog(params.playLogSyncs);
  }

  Future<Either<Failure, String>> sendScreenshot(ScreenshotParam param) async {
    return await _repository.sendScreenshot(param.imageData);
  }
}

class Params extends Equatable {
  const Params();

  @override
  List<Object> get props => [];
}

class RemarkParams extends Equatable {
  final String contentId;
  final String deviceId;
  final String url;
  final String savedAt;
  final String remark;
  const RemarkParams(
    this.contentId,
    this.deviceId,
    this.url,
    this.savedAt,
    this.remark,
  );

  @override
  List<Object> get props => [contentId, deviceId, url, savedAt, remark];
}

class PlayLogSyncParam extends Equatable {
  final List<LogSyncRequest> playLogSyncs;
  const PlayLogSyncParam(
    this.playLogSyncs,
  );

  @override
  List<Object> get props => [playLogSyncs];
}

class ScreenshotParam extends Equatable {
  final String imageData;
  const ScreenshotParam(
    this.imageData,
  );

  @override
  List<Object> get props => [imageData];
}
