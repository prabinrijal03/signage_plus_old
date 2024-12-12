part of 'information_bloc.dart';

sealed class InformationState extends Equatable {
  const InformationState();

  @override
  List<Object> get props => [];
}

final class InformationLoading extends InformationState {}

final class InformationLoaded extends InformationState {
  final String deviceName;
  final int brightness;
  final int volume;
  final bool displayDate;
  final String dateFormat;
  final bool displayWeather;
  final bool displayDeviceName;
  final String location;
  final String language;
  final bool isActive;
  final bool isAssigned;
  final Color primaryColor;
  final Color secondaryColor;

  const InformationLoaded({
    required this.deviceName,
    required this.brightness,
    required this.volume,
    required this.displayDate,
    required this.dateFormat,
    required this.displayWeather,
    required this.displayDeviceName,
    required this.location,
    required this.language,
    required this.isActive,
    required this.isAssigned,
    this.primaryColor = ColorManager.secondary,
    this.secondaryColor = ColorManager.white,
  });

  @override
  List<Object> get props => [
        deviceName,
        brightness,
        volume,
        displayDate,
        dateFormat,
        displayWeather,
        displayDeviceName,
        location,
        language,
        isActive,
        isAssigned,
        primaryColor,
        secondaryColor
      ];

  InformationLoaded copyWith({
    String? deviceName,
    int? brightness,
    int? volume,
    bool? displayDate,
    String? dateFormat,
    bool? displayWeather,
    bool? displayDeviceName,
    String? location,
    String? language,
    bool? isActive,
    bool? isAssigned,
    Color? primaryColor,
    Color? secondaryColor,
  }) {
    return InformationLoaded(
      deviceName: deviceName ?? this.deviceName,
      brightness: brightness ?? this.brightness,
      volume: volume ?? this.volume,
      displayDate: displayDate ?? this.displayDate,
      dateFormat: dateFormat ?? this.dateFormat,
      displayWeather: displayWeather ?? this.displayWeather,
      displayDeviceName: displayDeviceName ?? this.displayDeviceName,
      location: location ?? this.location,
      language: language ?? this.language,
      isActive: isActive ?? this.isActive,
      isAssigned: isAssigned ?? this.isAssigned,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
    );
  }
}

final class InformationError extends InformationState {
  final String message;

  const InformationError(this.message);

  @override
  List<Object> get props => [message];
}
