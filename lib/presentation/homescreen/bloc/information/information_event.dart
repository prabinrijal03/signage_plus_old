part of 'information_bloc.dart';

sealed class InformationEvent extends Equatable {
  const InformationEvent();

  @override
  List<Object> get props => [];
}

final class Initial extends InformationEvent {
  final DeviceInfo deviceInfo;
  const Initial({required this.deviceInfo});
}

final class UpdateInfo extends InformationEvent {
  final String? name;
  final int? brightness;
  final int? volume;
  final String? location;
  final bool? displayDate;
  final String? dateFormat;
  final bool? displayWeather;
  final bool? displayDeviceName;
  final String? language;
  final bool? isActive;
  final bool? isAssigned;
  final Color? primaryColor;
  final Color? secondaryColor;

  const UpdateInfo({
    this.language,
    this.displayDate,
    this.dateFormat,
    this.displayWeather,
    this.displayDeviceName,
    this.name,
    this.brightness,
    this.volume,
    this.location,
    this.isActive,
    this.isAssigned,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  List<Object> get props => [
        displayDate!,
        dateFormat!,
        displayWeather!,
        displayDeviceName!,
        name!,
        brightness!,
        volume!,
        location!,
        language!,
        isActive!,
        isAssigned!,
        primaryColor!,
        secondaryColor!
      ];
}

final class ToggleLanguage extends InformationEvent {}

final class NoInternet extends InformationEvent {
  const NoInternet();
}
