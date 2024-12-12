import 'dart:collection';

import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extensions.dart';
import '../../../../data/model/devices.dart';
import '../../../../data/model/ward_settings.dart';
import '../../../../data/usecases/fetch_custom_user.dart' as c;
import '../../../../data/usecases/fetch_device_layout.dart';
import '../../../../data/usecases/fetch_ward_info.dart' as w;
import '../../bloc/wards_info/wards_info_bloc.dart';
import '../../bloc/wards_news/wards_news_bloc.dart';
import '../../bloc/wards_personnel/wards_personnel_bloc.dart';
import '../../../../resources/constants.dart';
import '../../../../services/utils.dart';

import '../../../../data/model/custom_user.dart';
import '../../../../data/model/device_layout.dart';
import '../../../../data/usecases/download_video.dart' as d;
import '../../../../services/hive_services.dart';
import '../../../../services/socket_services.dart';

part 'layouts_state.dart';

enum ForceOrientation { portraitLeft, portraitRight, landscapeTop, landscapeBottom }

class LayoutsCubit extends Cubit<LayoutsState> {
  final Device device;

  final WardsInfoBloc wardsInfoBloc;
  final WardsPersonnelBloc wardsPersonnelBloc;
  final WardsNewsBloc wardsNewsBloc;

  final FetchDeviceLayout fetchDeviceLayout;
  final c.FetchCustomUser fetchCustomUser;
  final w.FetchWardDetails fetchWardDetails;

  final d.Donwload downloadVideo;

  LayoutsCubit({
    required this.device,
    required this.wardsInfoBloc,
    required this.wardsPersonnelBloc,
    required this.wardsNewsBloc,
    required this.fetchDeviceLayout,
    required this.fetchCustomUser,
    required this.fetchWardDetails,
    required this.downloadVideo,
  }) : super(const LayoutsLoading()) {
    loadDeviceLayout();
  }

  HashMap<String, CustomUser> _customUserMap = HashMap<String, CustomUser>();
  WardSettings? _wardSettings;
  bool? isPortrait;

  Future<void> fetchWard({bool? hasFailed}) async {
    final result = await fetchWardDetails(const w.Params());
    result.fold((failure) {
      if (hasFailed != null) {
        emit(LayoutsError(failure.message));
        hasFailed = true;
      }
      return;
    }, (wardDetails) async {
      wardsInfoBloc.add(InitializeWardInfo(wardDetails.wardInfos!, wardDetails.wardContent!));
      wardsPersonnelBloc.add(InitializeWardPersonnel(wardDetails.wardPersonnel!));
      wardsNewsBloc.add(InitializeWardNews(wardDetails.wardNews!));

      final imageUrls = wardDetails.wardContent!.where((element) => element.type == 'image').map((e) => e.source).toList();
      final videoUrls = wardDetails.wardContent!.where((element) => element.type == 'video').map((e) => e.source).toList();
      await Utils.downloadWardContents(downloadVideo, imageUrls, videoUrls);
    });

    final settings = await fetchWardDetails.getSettings(const w.Params());
    settings.fold((failure) {
      if (hasFailed != null) {
        emit(LayoutsError(failure.message));
        hasFailed = true;
      }
      return;
    }, (wardSettings) => _wardSettings = wardSettings);
  }

  // Init: Load device layout
  Future<void> loadDeviceLayout() async {
    final String? paddingString = HiveService().getPadding();
    final String? stopDurationString = HiveService().getStopDuration();
    ForceOrientation forceOrientation = ForceOrientation.landscapeBottom;

    SocketService().deviceStatus.listen((event) async {
      if (!event) {
        emit(LayoutsInactive(deviceName: device.name, forceOrientation: forceOrientation));
      } else {
        if (state is LayoutsInactive) {
          emit(LayoutsLoading(forceOrientation: forceOrientation));
          loadDeviceLayout();
        }
      }
    });

    SocketService().addCustomUser.listen((event) {
      if (event is Left) {
        _customUserMap[event.left.id] = event.left;
      } else {
        _customUserMap.remove(event.right);
      }
      emit((state as LayoutsLoaded).copyWith(customUsers: _customUserMap.values.toList(), shouldRebuild: true));
    });

    SocketService().customUserCondition.listen((event) {
      final userId = event[0] as String;
      final newCondition = event[1] as bool;

      if (_customUserMap.containsKey(userId)) {
        final user = _customUserMap[userId]!;
        _customUserMap[userId] = user.copyWith(condition: newCondition);
        emit((state as LayoutsLoaded).copyWith(customUsers: _customUserMap.values.toList(), shouldRebuild: false));
      }
    });

    SocketService().wardSettings.listen((event) {
      _wardSettings = event;
      emit((state as LayoutsLoaded).copyWith(wardSettings: event, shouldRebuild: true));
    });

    SocketService().wardDetailsStream.listen((event) {
      if (event is Left) {
        if (event.left.wardInfos!.isNotEmpty) {
          wardsInfoBloc.add(AddWardInfo(event.left.wardInfos!.first));
        }
        if (event.left.wardPersonnel!.isNotEmpty) {
          wardsPersonnelBloc.add(AddWardPersonnel(event.left.wardPersonnel!.first));
        }
        if (event.left.wardNews!.isNotEmpty) {
          wardsNewsBloc.add(AddWardNews(event.left.wardNews!.first));
        }
        if (event.left.wardContent!.isNotEmpty) {
          wardsInfoBloc.add(AddWardContent(event.left.wardContent!.first));
        }
      } else {
        if (event.right.wardInfos!.isNotEmpty) {
          wardsInfoBloc.add(UpdateWardInfo(event.right.wardInfos!.first));
        }
        if (event.right.wardPersonnel!.isNotEmpty) {
          wardsPersonnelBloc.add(UpdateWardPersonnel(event.right.wardPersonnel!.first));
        }
        if (event.right.wardNews!.isNotEmpty) {
          wardsNewsBloc.add(UpdateWardNews(event.right.wardNews!.first));
        }
        if (event.right.wardContent!.isNotEmpty) {
          wardsInfoBloc.add(UpdateWardContent(event.right.wardContent!.first));
        }
      }
    });

    SocketService().deleteWardStream.listen((event) {
      if (event['wardInfos'] != null) {
        wardsInfoBloc.add(RemoveWardInfo(event['wardInfos']));
      }

      if (event['wardNews'] != null) {
        wardsNewsBloc.add(RemoveWardNews(event['wardNews']));
      }

      if (event['wardPersonnels'] != null) {
        wardsPersonnelBloc.add(RemoveWardPersonnel(event['wardPersonnels']));
      }

      if (event['wardFiles'] != null) {
        wardsInfoBloc.add(RemoveWardContent(event['wardFiles'].first));
      }
    });

    SocketService().customUserCondition.listen((event) {
      final userId = event[0] as String;
      final newCondition = event[1] as bool;

      if (_customUserMap.containsKey(userId)) {
        final user = _customUserMap[userId]!;
        _customUserMap[userId] = user.copyWith(condition: newCondition);
        emit((state as LayoutsLoaded).copyWith(customUsers: _customUserMap.values.toList(), shouldRebuild: false));
      }
    });

    DeviceLayoutInfo? deviceLayoutInfo;
    bool hasFailed = false;

    final result = await fetchDeviceLayout(Params(deviceId: device.id));
    result.fold(
      (failure) {
        emit(LayoutsError(failure.message, forceOrientation: forceOrientation));
        hasFailed = true;
        return;
      },
      (deviceLayout) => deviceLayoutInfo = deviceLayout,
    );

    if (hasFailed) return;
    // If device layout is null, emit LayoutsError
    if (deviceLayoutInfo == null) return emit(NoDeviceLayout(device.id, device.name, forceOrientation: forceOrientation));

    // Set orientation based on device orientation
    if (deviceLayoutInfo!.orientation == 'portrait' && HiveService().getOrientation() == "LEFT") {
      forceOrientation = ForceOrientation.portraitLeft;
    } else if (deviceLayoutInfo!.orientation == 'portrait' && HiveService().getOrientation() == "RIGHT") {
      forceOrientation = ForceOrientation.portraitRight;
    } else if (deviceLayoutInfo!.orientation == 'landscape' && HiveService().getOrientation() == "LEFT") {
      forceOrientation = ForceOrientation.landscapeBottom;
    } else if (deviceLayoutInfo!.orientation == 'landscape' && HiveService().getOrientation() == "RIGHT") {
      forceOrientation = ForceOrientation.landscapeTop;
    }

    if (deviceLayoutInfo!.type == AppConstants.layoutTypeCustom) {
      final result = await fetchCustomUser(c.Params(deviceId: device.id));
      result.fold((failure) {
        emit(LayoutsError(failure.message, forceOrientation: forceOrientation));
        hasFailed = true;
        return;
      }, (customUser) => _customUserMap = HashMap<String, CustomUser>.fromIterable(customUser, key: (e) => e.id, value: (e) => e));
    }

    if (deviceLayoutInfo!.type == AppConstants.layoutTypeWard) {
      await fetchWard(hasFailed: hasFailed);
    }

    // Listen to padding stream
    SocketService().paddingStream.listen((event) {
      // Store padding in hive
      HiveService().addPaddingToBox(event);
      // Emit LayoutsLoaded with new padding
      if (state is LayoutsLoaded) {
        return emit(LayoutsLoaded(
          layouts: deviceLayoutInfo!.json,
          padding: event.toEdgeInsets,
          stopDuration: (state as LayoutsLoaded).stopDuration,
          forceOrientation: (state as LayoutsLoaded).forceOrientation,
          type: deviceLayoutInfo!.type,
          customUsers: _customUserMap.values.toList(),
          wardSettings: (state as LayoutsLoaded).wardSettings,
          shouldRebuild: true,
        ));
      }
    });

    // Listen to stop duration stream
    SocketService().stopDurationStream.listen((event) {
      // Store stop duration in hive
      HiveService().addStopDurationToBox(event);
      // Emit LayoutsLoaded with new stop duration
      if (state is LayoutsLoaded) {
        return emit(LayoutsLoaded(
          layouts: deviceLayoutInfo!.json,
          padding: (state as LayoutsLoaded).padding,
          stopDuration: int.parse(event),
          type: deviceLayoutInfo!.type,
          forceOrientation: (state as LayoutsLoaded).forceOrientation,
          customUsers: _customUserMap.values.toList(),
          wardSettings: (state as LayoutsLoaded).wardSettings,
          shouldRebuild: true,
        ));
      }
    });

    // If padding is stored in hive, set padding else set default padding
    final EdgeInsetsGeometry padding;
    if (paddingString == null) {
      padding = const EdgeInsets.fromLTRB(0, 0, 0, 0);
    } else {
      padding = paddingString.toEdgeInsets;
    }

    // If padding is stored in hive, set padding else set default padding
    final int stopDuration;
    if (stopDurationString == null) {
      stopDuration = 60;
    } else {
      stopDuration = int.parse(stopDurationString);
    }

    if (state is! LayoutsLoaded) {
      emit(LayoutsLoaded(
        layouts: deviceLayoutInfo!.json,
        padding: padding,
        stopDuration: stopDuration,
        type: deviceLayoutInfo!.type,
        forceOrientation: forceOrientation,
        customUsers: _customUserMap.values.toList(),
        wardSettings: _wardSettings ?? const WardSettings(),
        shouldRebuild: true,
      ));
    }
  }

  void updateConditions(List<Condition> conditions) {
    for (Condition condition in conditions) {
      if (_customUserMap.containsKey(condition.userId)) {
        final user = _customUserMap[condition.userId]!;
        _customUserMap[condition.userId] = user.copyWith(condition: condition.condition);
      }
    }

    emit((state as LayoutsLoaded).copyWith(customUsers: _customUserMap.values.toList(), shouldRebuild: false));
  }

  EdgeInsetsGeometry get padding {
    if (state is LayoutsLoaded) {
      return (state as LayoutsLoaded).padding;
    } else {
      return const EdgeInsets.fromLTRB(0, 0, 0, 0);
    }
  }

  Future<void> changeOrientation(BuildContext context, ForceOrientation orientation) async {
    Utils.setDeviceDimentionsByOrientation(context, orientation);

    if (state is LayoutsLoaded) {
      final prevState = state as LayoutsLoaded;
      emit(LayoutsLoaded(
          layouts: prevState.layouts,
          padding: prevState.padding,
          stopDuration: prevState.stopDuration,
          forceOrientation: orientation,
          customUsers: prevState.customUsers,
          wardSettings: prevState.wardSettings,
          type: prevState.type));
    } else if (state is LayoutsInactive) {
      emit((state as LayoutsInactive).copyWith(forceOrientation: orientation));
    } else if (state is LayoutsError) {
      emit((state as LayoutsError).copyWith(forceOrientation: orientation));
    } else if (state is NoDeviceLayout) {
      emit((state as NoDeviceLayout).copyWith(forceOrientation: orientation));
    } else if (state is LayoutsLoading) {
      emit((state as LayoutsLoading).copyWith(forceOrientation: orientation));
    }
  }
}
