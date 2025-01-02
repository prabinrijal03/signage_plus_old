import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:slashplus/resources/constants.dart';
import '../data/model/ward_details.dart';
import '../data/model/ward_settings.dart';
import 'hive_services.dart';
import '../core/error/failures.dart';
import '../data/model/custom_user.dart';
import 'utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../data/model/contents.dart';
import '../data/model/device_layout.dart';
import '../data/model/devices.dart';
import '../data/model/scroll_text.dart';

class SocketService {
  static final SocketService _singleton = SocketService._internal();

  factory SocketService() {
    return _singleton;
  }

  SocketService._internal();

  io.Socket? socket;

  late DeviceInfo deviceInfo;

  // Padding Stream
  final StreamController<String> _paddingController =
      StreamController<String>.broadcast();
  Stream<String> get paddingStream => _paddingController.stream;

  // Stop Duration Stream
  final StreamController<String> _stopDurationController =
      StreamController<String>.broadcast();
  Stream<String> get stopDurationStream => _stopDurationController.stream;

  // Scroll Texts Stream
  final StreamController<Either<ScrollTexts, String>> _scrollTextController =
      StreamController<Either<ScrollTexts, String>>.broadcast();
  Stream<Either<ScrollTexts, String>> get scrollTextStream =>
      _scrollTextController.stream;

  // Update Scroll Texts Stream
  final StreamController<ScrollTexts> _updateScrollTextController =
      StreamController<ScrollTexts>.broadcast();
  Stream<ScrollTexts> get updateScrollTextStream =>
      _updateScrollTextController.stream;

  // Logout Stream
  final StreamController<int> _logoutStreamController =
      StreamController<int>.broadcast();
  Stream<int> get logout => _logoutStreamController.stream;

  // Logout Stream
  final StreamController<bool> _deviceStatusStreamController =
      StreamController<bool>.broadcast();
  Stream<bool> get deviceStatus => _deviceStatusStreamController.stream;

  // Command Stream
  final StreamController<List> _commandStreamController =
      StreamController<List>.broadcast();
  Stream<List> get command => _commandStreamController.stream;

  // Content Stream
  final StreamController<Either<Content, String>> _contentController =
      StreamController<Either<Content, String>>.broadcast();
  Stream<Either<Content, String>> get contentStream =>
      _contentController.stream;

  // Force Play Stream
  final StreamController<String> _forcePlayController =
      StreamController<String>.broadcast();
  Stream<String> get forcePlay => _forcePlayController.stream;

  // Force Play Stream
  final StreamController<String> _forcePlayWardController =
      StreamController<String>.broadcast();
  Stream<String> get forcePlayWard => _forcePlayWardController.stream;

  // Ward Details Stream
  final StreamController<Either<WardDetails, WardDetails>>
      _wardDetailsController =
      StreamController<Either<WardDetails, WardDetails>>.broadcast();
  Stream<Either<WardDetails, WardDetails>> get wardDetailsStream =>
      _wardDetailsController.stream;

  // Ward Settings Stream
  final StreamController<WardSettings> _wardSettingsController =
      StreamController<WardSettings>.broadcast();
  Stream<WardSettings> get wardSettings => _wardSettingsController.stream;

  // Ward Delete Stream
  final StreamController<Map<String, dynamic>> _deleteWardController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get deleteWardStream =>
      _deleteWardController.stream;

  // Update Content Stream
  final StreamController<Content> _updateContentController =
      StreamController<Content>.broadcast();
  Stream<Content> get updateContentStream => _updateContentController.stream;

  // Device Stream
  final StreamController<Either<DeviceInfo, DeviceInfo>> _deviceController =
      StreamController<Either<DeviceInfo, DeviceInfo>>.broadcast();
  Stream<Either<DeviceInfo, DeviceInfo>> get deviceStream =>
      _deviceController.stream;

  // Custom User Stream
  final StreamController<Either<CustomUser, String>> _customUserController =
      StreamController<Either<CustomUser, String>>.broadcast();
  Stream<Either<CustomUser, String>> get addCustomUser =>
      _customUserController.stream;

  // Custom User Condition Stream
  final StreamController<List> _customUserConditionController =
      StreamController<List>.broadcast();
  Stream<List> get customUserCondition => _customUserConditionController.stream;

  // Ward Order Stream
  final StreamController<Map<String, dynamic>> _wardOrderController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get wardOrder => _wardOrderController.stream;

  void emitCommandResult(String sessionId, String result) {
    debugPrint(
        "Emiting to 'command' with data [{sessionId: $sessionId, command: 106, result: $result}]");
    socket?.emit('command', [
      {
        'sessionId': sessionId,
        'command': 106,
        'result': result,
      }
    ]);
  }

  void initSocket(String deviceId) {
    // Initialize socket
    socket = io.io(
      UrlConstants.baseUrl,
      io.OptionBuilder().setTransports(['websocket']).setAuth({
        "Authorization": "Bearer ${HiveService().getAccessToken()}",
        "Device": "mobile"
      }).build(),
    );

    socket?.onConnect((data) {
      debugPrint("Connected to socket. Sending device id : $deviceId");
      // join room
      socket?.emit('addNewUser', deviceId);
    });

    socket?.on('padding', (data) {
      if (data == null) return;
      // on padding received from socket
      debugPrint("Padding ::: $data");
      _paddingController.add(data);
    });

    socket?.on('stopDuration', (data) {
      if (data == null) return;
      // on padding received from socket
      debugPrint("Stop Duration ::: $data");
      _stopDurationController.add(data);
    });

    socket?.on('deviceInfo', (data) {
      // on device info received from socket
      // add to deviceStream
      debugPrint("Device Info Received :::: $data");

      try {
        deviceInfo = DeviceInfo.fromJson(data);

        // If device unassigned missed due to no internet
        if (!deviceInfo.isAssigned) {
          Utils.logout();
          return;
        }

        _deviceController.add(Left(deviceInfo));
      } catch (e) {
        deviceInfo = deviceInfo.copyWithFromJson(data);
        // If device unassigned missed due to no internet
        if (!deviceInfo.isAssigned) {
          Utils.logout();
          return;
        }
        _deviceController.add(Right(deviceInfo));
      }
    });

    socket?.on("scrollTextCreated", (data) {
      // on scroll texts received from socket
      // add to scrollTextStream
      debugPrint("Scroll Texts Received ::: $data");
      ScrollTexts scrollTexts = ScrollTexts.fromJson(data);
      _scrollTextController.add(Left(scrollTexts));
    });

    socket?.on("scrollTextUpdated", (data) {
      // on scroll texts received from socket
      // add to scrollTextStream
      debugPrint("Updated Scroll Texts Received ::: $data");
      ScrollTexts scrollTexts = ScrollTexts.fromJson(data);
      _updateScrollTextController.add(scrollTexts);
    });

    socket?.on("scrollTextDeleted", (data) {
      // on scroll texts deleted from socket
      // delete from scrollTextStream
      debugPrint("Scroll Text Deleted ::: $data");
      _scrollTextController.add(Right(data));
    });

    // on device unassigned from socket
    // add to logout stream
    socket?.on('deviceUnassigned', (data) async {
      debugPrint("Device Unassigned");
      _logoutStreamController.add(1);
    });

    // on device unassigned from socket
    // add to logout stream
    socket?.on('deviceStatus', (data) async {
      debugPrint("Device Status ::: $data");
      _deviceStatusStreamController.add(data);
    });

    // on content received from socket
    // add to content stream
    socket?.on("createdContent", (data) {
      debugPrint("Contents Received ::: $data");
      for (Map<String, dynamic> contentData in data) {
        Content content = Content.fromJson(contentData);
        _contentController.add(Left(content));
      }
    });

    // on content updated from socket
    // update content stream
    socket?.on("updatedContent", (data) {
      debugPrint("Content Updated ::: $data");
      for (Map<String, dynamic> contentData in data) {
        Content content = Content.fromJson(contentData);
        _updateContentController.add(content);
      }
    });

    // on content deleted from socket
    // delete from content stream
    socket?.on("deletedContent", (data) {
      debugPrint("Content Deleted ::: $data");
      _contentController.add(Right(data));
    });

    // on device command from socket
    // add to command stream
    socket?.on('command', (data) async {
      debugPrint("Command Received ::: $data");
      _commandStreamController.add(data);
    });

    // on force play from socket
    // add to force play controller stream
    socket?.on('forcePlay', (data) async {
      debugPrint("Force Play Received ::::: $data");
      print("Force Play Received ::::: $data");
      _forcePlayController.add(data);
    });

    // on custom user added from socket
    // add to custom user stream
    socket?.on('customUserAdded', (data) async {
      debugPrint("Custom User Added : $data");
      for (Map<String, dynamic> customUserData in data) {
        CustomUser customUser = CustomUser.fromJson(customUserData);
        _customUserController.add(Left(customUser));
      }
    });

    // on custom user deleted from socket
    // add to custom user stream
    socket?.on('customUserDeleted', (data) async {
      debugPrint("Custom User Deleted : $data");
      for (String id in data) {
        _customUserController.add(Right(id));
      }
    });

    socket?.on('condition', (data) async {
      debugPrint("Custom User Condition : $data");
      _customUserConditionController.add(data);
    });

    // on ward received from socket
    // add to ward stream
    socket?.on("wardCreated", (data) {
      debugPrint("Create Ward Received ::: $data");
      WardDetails wardDetails = WardDetails.fromJson(data);
      _wardDetailsController.add(Left(wardDetails));
    });

    // on ward updated from socket
    // update ward stream
    socket?.on("wardUpdated", (data) {
      debugPrint("Update Ward Received ::: $data");
      WardDetails wardDetails = WardDetails.fromJson(data);
      _wardDetailsController.add(Right(wardDetails));
    });

    // on deleted ward id received from socket
    // add to ward delete stream
    socket?.on("wardDeleted", (data) {
      debugPrint("Delete Ward Received ::: $data");
      _deleteWardController.add(data);
    });

    // on ward order changed from socket
    // add to ward order stream
    socket?.on("orderChanged", (data) {
      debugPrint("Ward Order Changed Received ::: $data");
      _wardOrderController.add(data['changedOrder']);
    });

    // on ward setting changed from socket
    // add to ward order stream
    socket?.on("wardSettingUpdated", (data) {
      debugPrint("Ward Setting Updated Received ::: $data");
      WardSettings wardSettings = WardSettings.fromJson(data);
      _wardSettingsController.add(wardSettings);
    });

    socket?.on("forcePlayWard", (data) {
      debugPrint("Force Play Ward Received ::: $data");
      print("Force Play ward Received ::::: $data");

      _forcePlayWardController.add(data);
    });
  }

  void dispose() {
    _scrollTextController.close();
    _logoutStreamController.close();
    _contentController.close();
    _updateContentController.close();
    _updateScrollTextController.close();
    _deviceController.close();
    _commandStreamController.close();
    _customUserController.close();
    _customUserConditionController.close();
    _deviceStatusStreamController.close();
    _paddingController.close();
    _stopDurationController.close();
    _wardDetailsController.close();
    _deleteWardController.close();
    _wardOrderController.close();
    _wardSettingsController.close();
  }

  Future<DeviceLayoutInfo?> assignDevice(String deviceId) async {
    // Assign device to user
    Completer<DeviceLayoutInfo?> completer = Completer<DeviceLayoutInfo?>();
    // emit assignDevice event with deviceId
    socket?.emit('assignDevice', deviceId);
    // on device assigned from socket
    socket?.on("deviceAssigned", (data) {
      debugPrint("Device Assigned ::: $data");
      completer.completeError(const Failure(
          message:
              "Device Layout Not Found. Please add device layout and try again."));
      // complete the future with device layout info
      DeviceLayoutInfo deviceLayout = DeviceLayoutInfo.fromJson(data);
      completer.complete(deviceLayout);
    });
    // on device assign failed from socket
    socket?.on('deviceAssignFailed', (data) {
      debugPrint("Device Assign Failed ::: $data");
      // complete the future with error
      completer.completeError(const Failure(
          message:
              "Device Assign Failed. Please contact your system administrator."));
    });
    // return future
    DeviceLayoutInfo? deviceLayout = await completer.future;
    return deviceLayout;
  }

  void sendScreenshot(bool success, String data, String token) {
    socket?.emit('screenshotImage', [success, data, token]);
  }
}
