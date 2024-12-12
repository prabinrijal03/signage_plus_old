import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:slashplus/core/extensions.dart';

class Devices {
  final List<Device> devices;

  const Devices({
    required this.devices,
  });

  factory Devices.fromJson(List<dynamic> json) {
    return Devices(
      devices: json.map((e) => Device.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'devices': devices.map((e) => e.toJson()).toList(),
    };
  }
}

class Device {
  final String id;
  final String name;

  const Device({
    required this.id,
    required this.name,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['deviceID'],
      name: json['deviceName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceID': id,
      'deviceName': name,
    };
  }
}

class DeviceAdapter extends TypeAdapter<Device> {
  @override
  final int typeId = 0;

  @override
  Device read(BinaryReader reader) {
    return Device(
      id: reader.readString(),
      name: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Device obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
  }
}

// ----------- Device Info -----------

class DeviceInfo {
  final String name;
  final int brightness;
  final int volume;
  final bool showDateTime;
  final String dateFormat;
  final bool showWeather;
  final bool showDeviceName;
  final String language;
  final String location;
  final bool isActive;
  final bool isAssigned;
  final Color primaryColor;
  final Color secondaryColor;

  const DeviceInfo({
    required this.name,
    required this.brightness,
    required this.volume,
    required this.showDateTime,
    required this.dateFormat,
    required this.showWeather,
    required this.showDeviceName,
    required this.language,
    required this.location,
    required this.isActive,
    required this.isAssigned,
    required this.primaryColor,
    required this.secondaryColor,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      name: json['deviceName'],
      brightness: json['brightness'],
      volume: json['volume'],
      showDateTime: json['showDateTime'],
      dateFormat: json['dateFormat'] ?? "EEEE | h:mm:ss a",
      showWeather: json['showWeather'],
      showDeviceName: json['showDeviceName'],
      language: json['language'],
      location: json['location'],
      isActive: json['isActive'],
      isAssigned: json['isAssigned'],
      primaryColor: (json['primaryColor'] as String).toColor,
      secondaryColor: (json['secondaryColor'] as String).toColor,
    );
  }

  DeviceInfo copyWithFromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      name: json['deviceName'] ?? name,
      brightness: json['brightness'] ?? brightness,
      volume: json['volume'] ?? volume,
      showDateTime: json['showDateTime'] ?? showDateTime,
      dateFormat: json['dateFormat'] ?? dateFormat,
      showWeather: json['showWeather'] ?? showWeather,
      showDeviceName: json['showDeviceName'] ?? showDeviceName,
      language: json['language'] ?? language,
      location: json['location'] ?? location,
      isActive: json['isActive'] ?? isActive,
      isAssigned: json['isAssigned'] ?? isAssigned,
      primaryColor: json['primaryColor'] ?? primaryColor,
      secondaryColor: json['secondaryColor'] ?? secondaryColor,
    );
  }
}
