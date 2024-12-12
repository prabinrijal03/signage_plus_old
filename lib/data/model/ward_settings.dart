import 'package:hive_flutter/adapters.dart';

class WardSettings {
  final int? wardInfoScrollSpeed;
  final int? wardNewsScrollSpeed;
  final int? wardPersonnelDisplayTime;
  final int? wardInfoDisplayTime;
  final int? wardNewsDisplayTime;
  final int? wardPersonnelHeight;
  final int? wardInfoHeight;
  final int? wardNewsHeight;

  const WardSettings({
    this.wardInfoScrollSpeed,
    this.wardNewsScrollSpeed,
    this.wardPersonnelDisplayTime,
    this.wardInfoDisplayTime,
    this.wardNewsDisplayTime,
    this.wardPersonnelHeight,
    this.wardInfoHeight,
    this.wardNewsHeight,
  });

  factory WardSettings.fromJson(Map<String, dynamic> json) {
    return WardSettings(
      wardInfoScrollSpeed: json['Ward_Info_Scroll_Speed'],
      wardNewsScrollSpeed: json['Ward_News_Scroll_Speed'],
      wardPersonnelDisplayTime: json['Ward_Personnel_Display_Time'],
      wardInfoDisplayTime: json['Ward_Info_Display_Time'],
      wardNewsDisplayTime: json['Ward_News_Display_Time'],
      wardPersonnelHeight: json['Ward_Personnel_Height'],
      wardInfoHeight: json['Ward_Info_Height'],
      wardNewsHeight: json['Ward_News_Height'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Ward_Info_Scroll_Speed': wardInfoScrollSpeed,
      'Ward_News_Scroll_Speed': wardNewsScrollSpeed,
      'Ward_Personnel_Display_Time': wardPersonnelDisplayTime,
      'Ward_Info_Display_Time': wardInfoDisplayTime,
      'Ward_News_Display_Time': wardNewsDisplayTime,
      'Ward_Personnel_Height': wardPersonnelHeight,
      'Ward_Info_Height': wardInfoHeight,
      'Ward_News_Height': wardNewsHeight,
    };
  }
}

class WardSettingsAdapater extends TypeAdapter<WardSettings> {
  @override
  final int typeId = 13;

  @override
  WardSettings read(BinaryReader reader) {
    return WardSettings(
      wardInfoScrollSpeed: reader.read(),
      wardNewsScrollSpeed: reader.read(),
      wardPersonnelDisplayTime: reader.read(),
      wardInfoDisplayTime: reader.read(),
      wardNewsDisplayTime: reader.read(),
      wardPersonnelHeight: reader.read(),
      wardInfoHeight: reader.read(),
      wardNewsHeight: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, WardSettings obj) {
    writer
      ..write(obj.wardInfoScrollSpeed)
      ..write(obj.wardNewsScrollSpeed)
      ..write(obj.wardPersonnelDisplayTime)
      ..write(obj.wardInfoDisplayTime)
      ..write(obj.wardNewsDisplayTime)
      ..write(obj.wardPersonnelHeight)
      ..write(obj.wardInfoHeight)
      ..write(obj.wardNewsHeight);
  }
}
