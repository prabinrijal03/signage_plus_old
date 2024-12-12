import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slashplus/resources/color_manager.dart';
import 'package:slashplus/services/hive_services.dart';
import '../../../../data/model/devices.dart';
import '../../../../resources/constants.dart';
import '../../../../services/screen_brightness.dart';
import '../../../../services/socket_services.dart';

part 'information_event.dart';
part 'information_state.dart';

class InformationBloc extends Bloc<InformationEvent, InformationState> {
  final ScreenBrightness screenBrightness;

  InformationBloc({required this.screenBrightness}) : super(InformationLoading()) {
    on<Initial>((event, emit) async {
      HiveService.addVolume(event.deviceInfo.volume);

      emit(InformationLoaded(
        deviceName: event.deviceInfo.name,
        brightness: event.deviceInfo.brightness,
        volume: event.deviceInfo.volume,
        displayDate: event.deviceInfo.showDateTime,
        dateFormat: event.deviceInfo.dateFormat,
        displayWeather: event.deviceInfo.showWeather,
        displayDeviceName: event.deviceInfo.showDeviceName,
        location: event.deviceInfo.location,
        language: event.deviceInfo.language,
        isActive: event.deviceInfo.isActive,
        isAssigned: event.deviceInfo.isAssigned,
        primaryColor: event.deviceInfo.primaryColor,
        secondaryColor: event.deviceInfo.secondaryColor,
      ));
    });

    on<UpdateInfo>((event, emit) {
      HiveService.addVolume(event.volume);

      emit((state as InformationLoaded).copyWith(
        deviceName: event.name,
        brightness: event.brightness,
        volume: event.volume,
        displayDate: event.displayDate,
        dateFormat: event.dateFormat,
        displayWeather: event.displayWeather,
        displayDeviceName: event.displayDeviceName,
        location: event.location,
        language: event.language,
        isActive: event.isActive,
        isAssigned: event.isAssigned,
        primaryColor: event.primaryColor,
        secondaryColor: event.secondaryColor,
      ));
    });
  }

  Future<void> init() async {
    SocketService().socket?.emit("getDeviceInfo", AppConstants.deviceId);
    SocketService().deviceStream.listen((event) {
      (event.isLeft)
          ? add(Initial(deviceInfo: event.left))
          : add(UpdateInfo(
              name: event.right.name,
              brightness: event.right.brightness,
              volume: event.right.volume,
              displayDate: event.right.showDateTime,
              dateFormat: event.right.dateFormat,
              displayWeather: event.right.showWeather,
              displayDeviceName: event.right.showDeviceName,
              location: event.right.location,
              language: event.right.language,
              isActive: event.right.isActive,
              isAssigned: event.right.isAssigned,
              primaryColor: event.right.primaryColor,
              secondaryColor: event.right.secondaryColor,
            ));
    });
  }

  int get volume {
    if (state is! InformationLoaded) return HiveService.getVolume();
    return (state as InformationLoaded).volume;
  }

  bool? get isActive {
    if (state is! InformationLoaded) return null;
    return (state as InformationLoaded).isActive;
  }

  String get deviceName {
    if (state is! InformationLoaded) return '';
    return (state as InformationLoaded).deviceName;
  }

  bool? get isAssigned {
    if (state is! InformationLoaded) return null;
    return (state as InformationLoaded).isAssigned;
  }

  void setBrightness(double brightness) {
    screenBrightness.setScreenBrightness(brightness);
  }
}
