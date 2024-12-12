part of 'layouts_cubit.dart';

abstract class LayoutsState extends Equatable {
  final ForceOrientation forceOrientation;
  const LayoutsState({this.forceOrientation = ForceOrientation.landscapeBottom});

  @override
  List<Object> get props => [forceOrientation];
}

class LayoutsLoading extends LayoutsState {
  const LayoutsLoading({super.forceOrientation});

  @override
  List<Object> get props => [];

  LayoutsLoading copyWith({
    ForceOrientation? forceOrientation,
  }) {
    return LayoutsLoading(forceOrientation: forceOrientation ?? this.forceOrientation);
  }
}

class LayoutsLoaded extends LayoutsState {
  final DeviceLayout layouts;
  final int stopDuration;
  final EdgeInsetsGeometry padding;
  final String type;
  final List<CustomUser> customUsers;
  final WardSettings wardSettings;
  final bool shouldRebuild;

  const LayoutsLoaded({
    super.forceOrientation,
    required this.layouts,
    required this.stopDuration,
    required this.padding,
    required this.type,
    required this.customUsers,
    required this.wardSettings,
    this.shouldRebuild = true,
  });

  LayoutsLoaded copyWith(
      {DeviceLayout? layouts,
      EdgeInsetsGeometry? padding,
      ForceOrientation? forceOrientation,
      int? stopDuration,
      String? type,
      List<CustomUser>? customUsers,
      WardSettings? wardSettings,
      bool? shouldRebuild}) {
    return LayoutsLoaded(
      layouts: layouts ?? this.layouts,
      padding: padding ?? this.padding,
      stopDuration: stopDuration ?? this.stopDuration,
      type: type ?? this.type,
      customUsers: customUsers ?? this.customUsers,
      wardSettings: wardSettings ?? this.wardSettings,
      shouldRebuild: shouldRebuild ?? this.shouldRebuild,
    );
  }

  @override
  List<Object> get props => [layouts, padding, forceOrientation, stopDuration, type, customUsers, wardSettings, shouldRebuild];
}

class LayoutsError extends LayoutsState {
  final String message;
  const LayoutsError(this.message, {super.forceOrientation});

  @override
  List<Object> get props => [message];

  LayoutsError copyWith({
    String? message,
    ForceOrientation? forceOrientation,
  }) {
    return LayoutsError(
      message ?? this.message,
      forceOrientation: forceOrientation ?? this.forceOrientation,
    );
  }
}

class LayoutsInactive extends LayoutsState {
  final String deviceName;
  const LayoutsInactive({super.forceOrientation, required this.deviceName});

  @override
  List<Object> get props => [];

  LayoutsInactive copyWith({ForceOrientation? forceOrientation, String? deviceName}) {
    return LayoutsInactive(
      forceOrientation: forceOrientation ?? this.forceOrientation,
      deviceName: deviceName ?? this.deviceName,
    );
  }
}

class NoDeviceLayout extends LayoutsState {
  final String deviceId;
  final String deviceName;
  const NoDeviceLayout(this.deviceId, this.deviceName, {super.forceOrientation});

  @override
  List<Object> get props => [deviceId, deviceName];

  NoDeviceLayout copyWith({
    String? deviceId,
    String? deviceName,
    ForceOrientation? forceOrientation,
  }) {
    return NoDeviceLayout(
      forceOrientation: forceOrientation ?? this.forceOrientation,
      deviceId ?? this.deviceId,
      deviceName ?? this.deviceName,
    );
  }
}
