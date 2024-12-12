import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import '../model/contents.dart';
import '../model/custom_user.dart';
import '../model/device_layout.dart';
import '../model/devices.dart';
import '../model/feedback_questions.dart';
import '../model/play_log_sync.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/internet_checker.dart';
import '../../services/socket_services.dart';
import '../datasource/local_datasource.dart';
import '../datasource/remote_datasource.dart';
import '../model/scroll_text.dart';
import '../model/token.dart';
import '../model/user_information.dart';
import '../model/ward_details.dart';
import '../model/ward_settings.dart';

abstract class Repository {
  Future<Either<Failure, DateTime>> getServerDateTime();
  Future<Either<Failure, Device>> login(String loginCode);
  Future<Either<Failure, DeviceLayoutInfo?>> getDeviceLayout(String deviceId);
  Future<Either<Failure, ScrollTexts>> getScrollTexts();
  Future<Either<Failure, Contents>> getContents();
  Future<Either<Failure, bool>> download(String url, String path);
  Future<Either<Failure, ContentUrls>> getContentUrls();
  Future<Either<Failure, void>> sendContentRemarks(String contentId, String deviceId, String url, String savedAt, String remark);
  Future<Either<Failure, void>> sendScrollRemarks(String contentId, String deviceId, String url, String savedAt, String remark);
  Future<Either<Failure, List<String>>> syncPlayLog(List<LogSyncRequest> playLogSyncs);
  Future<Either<Failure, String>> sendScreenshot(String imageData);
  Future<Either<Failure, String>> setVersion(String deviceId, String versionId);
  Future<Either<Failure, bool>> checkDeviceId(String deviceId);

  // For Custom User
  Future<Either<Failure, List<CustomUser>>> getCustomUser(String deviceId);
  Future<Either<Failure, List<Condition>>> getCondition(String deviceId);

  // Ward Info
  Future<Either<Failure, WardDetails>> getWardDetails();
  Future<Either<Failure, WardSettings>> getWardSettings();

  // Token Feedback
  Future<Either<Failure, FeedbackQuestions>> getFeedbackQuestions();
  Future<Either<Failure, String>> postFeedback(Map<String, dynamic> feedback);

  // Token System
  Future<Either<Failure, Token>> generateToken(ApplicantInfoRequest userInfo);
}

class RepositoryImpl implements Repository {
  final RemoteDatasource remoteDataSource;
  final NetworkInfo networkInfo;
  final LocalDatasource localDataSource;

  const RepositoryImpl(this.remoteDataSource, this.localDataSource, this.networkInfo);

  @override
  Future<Either<Failure, DateTime>> getServerDateTime() async {
    if (await networkInfo.isConnected) {
      try {
        final dateTime = await remoteDataSource.getServerDateTime();
        return Right(dateTime);
      } on DioException catch (e) {
        debugPrint(e.message);
        return Left(Failure(message: "Error: ${e.response?.statusCode}: ${e.response?.statusMessage}"));
      } on ServerException catch (e) {
        debugPrint(e.message);
        return Left(Failure(message: e.message));
      } on Exception catch (e) {
        debugPrint(e.toString());
        return Left(Failure(message: e.toString()));
      }
    } else {
      return const Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, Device>> login(String code) async {
    if (await networkInfo.isConnected) {
      try {
        final devices = await remoteDataSource.login(code);

        if (devices.devices.isEmpty) {
          return const Left(Failure(message: "No device available. Please contact the administration."));
        }
        SocketService().initSocket(devices.devices.first.id);
        final assigned = await remoteDataSource.assignDevice(devices.devices.first.id);
        if (!assigned) {
          return const Left(Failure(message: "Device Assigned Failed. Please contact the system administrator."));
        }
        localDataSource.setDevice(devices.devices.first);
        return Right(devices.devices.first);
      } on DioException catch (e) {
        debugPrint(e.message);
        if (e.response?.statusCode == 404) {
          return const Left(Failure(message: "User not found. Please try again."));
        }
        if (e.response?.statusCode == 400) {
          return Left(Failure(message: e.response?.data['message'] ?? "Invalid login code. Please try again."));
        }
        if (e.response?.statusCode == 501) {
          return const Left(Failure(message: "Device Assigned Failed. Please contact the system administrator."));
        }
        return const Left(Failure(message: "Error 500: Internal Server Error. Please try again later."));
      } on ServerException catch (e) {
        debugPrint(e.message);
        return const Left(ServerFailure());
      } on Failure catch (e) {
        debugPrint(e.toString());
        return Left(Failure(message: e.message));
      }
    } else {
      return const Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, DeviceLayoutInfo?>> getDeviceLayout(String deviceId) async {
    if (await networkInfo.isConnected) {
      try {
        final deviceLayout = await remoteDataSource.getDeviceLayout(deviceId);
        localDataSource.cacheLayoutsInfo(deviceLayout);
        return Right(deviceLayout);
      } on DioException catch (e) {
        debugPrint(e.message);
        if (e.response?.statusCode == 404) return const Right(null);
        // return const Left(Failure(message: "Error 500: Internal Server Error. Please try again later."));
      } on ServerException catch (e) {
        debugPrint(e.message);
        // return const Left(ServerFailure());
      } on Exception catch (e) {
        debugPrint(e.toString());
        // return const Left(Failure(message: "Something went wrong. Please try again later."));
      }
    }
    try {
      final localDeviceLayout = await localDataSource.getCachedLayouts();
      return Right(localDeviceLayout);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, ScrollTexts>> getScrollTexts() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteInfo = await remoteDataSource.getScrollTexts();
        localDataSource.cacheScrollTexts(remoteInfo);
        return Right(remoteInfo);
      } on DioException catch (e) {
        debugPrint(e.message);
        // return const Left(Failure(message: "Error 500: Internal Server Error. Please try again later."));
      } on ServerException catch (e) {
        debugPrint(e.message);
        // return const Left(ServerFailure());
      } on Exception catch (e) {
        debugPrint(e.toString());
        // return const Left(Failure(message: "Something went wrong. Please try again later."));
      }
    }

    try {
      final localScrollTexts = await localDataSource.getScrollTexts();
      return Right(localScrollTexts);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Contents>> getContents() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteInfo = await remoteDataSource.getContents();
        localDataSource.cacheContents(remoteInfo);
        return Right(remoteInfo);
      } on DioException catch (e) {
        debugPrint(e.message);
        // return const Left(Failure(message: "Error 500: Internal Server Error. Please try again later."));
      } on ServerException catch (e) {
        debugPrint(e.message);
        // return const Left(ServerFailure());
      } on Exception catch (e) {
        debugPrint(e.toString());
        // return const Left(Failure(message: "Something went wrong. Please try again later."));
      }
    }
    try {
      final localContents = await localDataSource.getCachedContents();
      return Right(localContents);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> download(String url, String path) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.download(url, path);
        return const Right(true);
      } on DioException catch (e) {
        debugPrint(e.message);
        return const Left(Failure(message: "Error 500: Internal Server Error. Please try again later."));
      } on ServerException catch (e) {
        debugPrint(e.message);
        return const Left(ServerFailure());
      } on Exception catch (e) {
        debugPrint(e.toString());
        return const Left(Failure(message: "Something went wrong. Please try again later."));
      }
    } else {
      return const Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, ContentUrls>> getContentUrls() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteInfo = await remoteDataSource.getContentUrls();
        return Right(remoteInfo);
      } on DioException catch (e) {
        debugPrint(e.message);
        return const Left(Failure(message: "Error 500: Internal Server Error. Please try again later."));
      } on ServerException catch (e) {
        debugPrint(e.message);
        return const Left(ServerFailure());
      } on Exception catch (e) {
        debugPrint(e.toString());
        return const Left(Failure(message: "Something went wrong. Please try again later."));
      }
    } else {
      return const Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, void>> sendContentRemarks(String contentId, String deviceId, String url, String savedAt, String remark) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendContentRemarks(contentId, deviceId, url, savedAt, remark);
        return const Right(null);
      } on DioException catch (e) {
        debugPrint(e.message);
        return const Left(Failure(message: "Error 500: Internal Server Error. Please try again later."));
      } on ServerException catch (e) {
        debugPrint(e.message);
        return const Left(ServerFailure());
      } on Exception catch (e) {
        debugPrint(e.toString());
        return const Left(Failure(message: "Something went wrong. Please try again later."));
      }
    } else {
      return const Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, void>> sendScrollRemarks(String contentId, String deviceId, String url, String savedAt, String remark) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendScrollRemarks(contentId, deviceId, url, savedAt, remark);
        return const Right(null);
      } on DioException catch (e) {
        debugPrint(e.message);
        return const Left(Failure(message: "Error 500: Internal Server Error. Please try again later."));
      } on ServerException catch (e) {
        debugPrint(e.message);
        return const Left(ServerFailure());
      } on Exception catch (e) {
        debugPrint(e.toString());
        return const Left(Failure(message: "Something went wrong. Please try again later."));
      }
    } else {
      return const Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, List<String>>> syncPlayLog(List<LogSyncRequest> playLogSyncs) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteInfo = await remoteDataSource.syncPlayLog(playLogSyncs);
        return Right(remoteInfo);
      } on DioException catch (e) {
        debugPrint(e.message);
        return const Left(Failure(message: "Error 500: Internal Server Error. Please try again later."));
      } on ServerException catch (e) {
        debugPrint(e.message);
        return const Left(ServerFailure());
      } on Exception catch (e) {
        debugPrint(e.toString());
        return const Left(Failure(message: "Something went wrong. Please try again later."));
      }
    } else {
      return const Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, String>> sendScreenshot(String imageData) async {
    if (await networkInfo.isConnected) {
      try {
        final String id = await remoteDataSource.sendScreenshot(imageData);
        return Right(id);
      } on DioException catch (e) {
        debugPrint(e.message);
        return Left(Failure(message: "Error: ${e.response?.statusCode}: ${e.response?.statusMessage}"));
      } on ServerException catch (e) {
        debugPrint(e.message);
        return Left(Failure(message: e.message));
      } on Exception catch (e) {
        debugPrint(e.toString());
        return Left(Failure(message: e.toString()));
      }
    } else {
      return const Left(InternetConnectionFailure());
    }
  }

  // For Custom User
  @override
  Future<Either<Failure, List<CustomUser>>> getCustomUser(String deviceId) async {
    if (await networkInfo.isConnected) {
      try {
        final customUser = await remoteDataSource.getCustomUser(deviceId);
        return Right(customUser);
      } on DioException catch (e) {
        debugPrint(e.message);
        return const Left(Failure(message: "Error 500: Internal Server Error. Please try again later."));
      } on ServerException catch (e) {
        debugPrint(e.message);
        return const Left(ServerFailure());
      } on Exception catch (e) {
        debugPrint(e.toString());
        return const Left(Failure(message: "Something went wrong. Please try again later."));
      }
    } else {
      try {
        final localCustomUser = await localDataSource.getCustomUser();
        return Right(localCustomUser);
      } on CacheException {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<Condition>>> getCondition(String deviceId) async {
    if (await networkInfo.isConnected) {
      try {
        final condition = await remoteDataSource.getCondition(deviceId);
        if (condition.isEmpty) {
          return const Left(Failure(message: "No condition available. Please contact the administration."));
        }
        return Right(condition);
      } on DioException catch (e) {
        debugPrint(e.message);
        return const Left(Failure(message: "Error 500: Internal Server Error. Please try again later."));
      } on ServerException catch (e) {
        debugPrint(e.message);
        return const Left(ServerFailure());
      } on Exception catch (e) {
        debugPrint(e.toString());
        return const Left(Failure(message: "Something went wrong. Please try again later."));
      }
    } else {
      return const Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> checkDeviceId(String deviceId) async {
    if (await networkInfo.isConnected) {
      try {
        final bool isDeviceIdAvailable = await remoteDataSource.checkDeviceId(deviceId);
        return Right(isDeviceIdAvailable);
      } on DioException catch (e) {
        debugPrint(e.message);
        return const Left(Failure(message: "Error 500: Internal Server Error. Please try again later."));
      } on Exception catch (e) {
        debugPrint(e.toString());
        return const Left(Failure(message: "Something went wrong. Please try again later."));
      }
    } else {
      return const Left(InternetConnectionFailure());
    }
  }

  // Ward Info
  @override
  Future<Either<Failure, WardDetails>> getWardDetails() async {
    if (await networkInfo.isConnected) {
      try {
        final wardDetails = await remoteDataSource.getWardDetails();
        localDataSource.cacheWardDetails(wardDetails);
        if (wardDetails.wardContent != null) {
          localDataSource.cacheWardContents(wardDetails.wardContent!);
        }
        return Right(wardDetails);
      } on DioException catch (e) {
        debugPrint(e.message);
      } on ServerException catch (e) {
        debugPrint(e.message);
      } on Exception catch (e) {
        debugPrint(e.toString());
      }
    }
    try {
      final localWardDetails = await localDataSource.getWardDetails();
      return Right(localWardDetails);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, WardSettings>> getWardSettings() async {
    if (await networkInfo.isConnected) {
      try {
        final wardSettings = await remoteDataSource.getWardSettings();
        localDataSource.cacheWardSettings(wardSettings);
        return Right(wardSettings);
      } on DioException catch (e) {
        debugPrint(e.message);
      } on ServerException catch (e) {
        debugPrint(e.message);
      } on Exception catch (e) {
        debugPrint(e.toString());
      }
    }
    try {
      final localWardSettings = await localDataSource.getWardSettings();
      return Right(localWardSettings);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, String>> setVersion(String deviceId, String versionId) async {
    if (await networkInfo.isConnected) {
      try {
        final String id = await remoteDataSource.setVersion(deviceId, versionId);
        return Right(id);
      } on DioException catch (e) {
        debugPrint(e.message);
        return Left(Failure(message: "Error: ${e.response?.statusCode}: ${e.response?.statusMessage}"));
      } on ServerException catch (e) {
        debugPrint(e.message);
        return Left(Failure(message: e.message));
      } on Exception catch (e) {
        debugPrint(e.toString());
        return Left(Failure(message: e.toString()));
      }
    } else {
      return const Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, FeedbackQuestions>> getFeedbackQuestions() async {
    if (await networkInfo.isConnected) {
      try {
        final feedbackQuestions = await remoteDataSource.getFeedbackQuestions();
        return Right(feedbackQuestions);
      } on DioException catch (e) {
        debugPrint(e.message);
        return const Left(Failure(message: "Error 500: Internal Server Error. Please try again later."));
      } on ServerException catch (e) {
        debugPrint(e.message);
        return const Left(ServerFailure());
      } on Exception catch (e) {
        debugPrint(e.toString());
        return const Left(Failure(message: "Something went wrong. Please try again later."));
      }
    } else {
      return const Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, String>> postFeedback(Map<String, dynamic> feedback) async {
    if (await networkInfo.isConnected) {
      try {
        final String id = await remoteDataSource.postFeedback(feedback);
        return Right(id);
      } on DioException catch (e) {
        debugPrint(e.message);
        return Left(Failure(message: "Error: ${e.response?.statusCode}: ${e.response?.statusMessage}"));
      } on ServerException catch (e) {
        debugPrint(e.message);
        return Left(Failure(message: e.message));
      } on Exception catch (e) {
        debugPrint(e.toString());
        return Left(Failure(message: e.toString()));
      }
    } else {
      return const Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, Token>> generateToken(ApplicantInfoRequest userInfo) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.generateToken(userInfo);
        return Right(response);
      } on DioException catch (e) {
        debugPrint(e.message);
        return const Left(Failure(message: "Error 500: Internal Server Error. Please try again later."));
      } on ServerException catch (e) {
        debugPrint(e.message);
        return const Left(ServerFailure());
      } on Exception catch (e) {
        debugPrint(e.toString());
        return const Left(Failure(message: "Something went wrong. Please try again later."));
      }
    } else {
      return const Left(InternetConnectionFailure());
    }
  }
}
