import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../../core/extensions.dart';

import '../../services/utils.dart';

class WardDetails {
  final List<WardInfo>? wardInfos;
  final List<WardNews>? wardNews;
  final List<WardPersonnel>? wardPersonnel;
  final List<WardContent>? wardContent;

  const WardDetails({
    this.wardInfos,
    this.wardNews,
    this.wardPersonnel,
    this.wardContent,
  });

  factory WardDetails.fromJson(Map<String, dynamic> json) {
    return WardDetails(
      wardInfos:
          json['wardInfos'] == null ? [] : (json['wardInfos'] as List<dynamic>).map((e) => WardInfo.fromJson(e as Map<String, dynamic>)).toList(),
      wardNews: json['wardNews'] == null ? [] : (json['wardNews'] as List<dynamic>).map((e) => WardNews.fromJson(e as Map<String, dynamic>)).toList(),
      wardPersonnel: json['wardPersonnels'] == null
          ? []
          : (json['wardPersonnels'] as List<dynamic>).map((e) => WardPersonnel.fromJson(e as Map<String, dynamic>)).toList(),
      wardContent:
          json['wardFiles'] == null ? [] : (json['wardFiles'] as List<dynamic>).map((e) => WardContent.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wardInfos': wardInfos?.map((e) => e.toJson()).toList(),
      'wardNews': wardNews?.map((e) => e.toJson()).toList(),
      'wardPersonnels': wardPersonnel?.map((e) => e.toJson()).toList(),
      'wardFiles': wardContent?.map((e) => e.toJson()).toList(),
    };
  }

  WardDetails copyWith({
    List<WardInfo>? wardInfos,
    List<WardNews>? wardNews,
    List<WardPersonnel>? wardPersonnel,
    List<WardContent>? wardContent,
  }) {
    return WardDetails(
      wardInfos: wardInfos ?? this.wardInfos,
      wardNews: wardNews ?? this.wardNews,
      wardPersonnel: wardPersonnel ?? this.wardPersonnel,
      wardContent: wardContent ?? this.wardContent,
    );
  }

  WardDetails addWardDetails(WardDetails wardDetails) {
    wardInfos?.addAll(wardDetails.wardInfos ?? []);
    wardNews?.addAll(wardDetails.wardNews ?? []);
    wardPersonnel?.addAll(wardDetails.wardPersonnel ?? []);

    return this;
  }

  void updateWardDetails(WardDetails wardDetails) {
    if (wardDetails.wardInfos != null) {
      final updatedWardInfo = wardDetails.wardInfos!.first;
      final index = wardInfos?.indexWhere((element) => element.id == updatedWardInfo.id);

      if (index == null) return;

      if (index != -1) {
        wardInfos![index] = updatedWardInfo;
      } else {
        wardInfos?.addAll(wardDetails.wardInfos ?? []);
      }
    }

    if (wardDetails.wardNews != null) {
      final updatedWardNews = wardDetails.wardNews!.first;
      final index = wardNews?.indexWhere((element) => element.id == updatedWardNews.id);

      if (index == null) return;

      if (index != -1) {
        wardNews![index] = updatedWardNews;
      } else {
        wardNews?.addAll(wardDetails.wardNews ?? []);
      }
    }

    if (wardDetails.wardPersonnel != null) {
      final updatedWardPersonnel = wardDetails.wardPersonnel!.first;
      final index = wardPersonnel?.indexWhere((element) => element.id == updatedWardPersonnel.id);

      if (index == null) return;

      if (index != -1) {
        wardPersonnel![index] = updatedWardPersonnel;
      } else {
        wardPersonnel?.addAll(wardDetails.wardPersonnel ?? []);
      }
    }
  }
}

class WardDetailsAdapter extends TypeAdapter<WardDetails> {
  @override
  final int typeId = 11;

  @override
  WardDetails read(BinaryReader reader) {
    return WardDetails(
      wardInfos: reader.readList().map((e) => e as WardInfo).toList(),
      wardNews: reader.readList().map((e) => e as WardNews).toList(),
      wardPersonnel: reader.readList().map((e) => e as WardPersonnel).toList(),
    );
  }

  @override
  void write(BinaryWriter writer, WardDetails obj) {
    writer.writeList(obj.wardInfos ?? []);
    writer.writeList(obj.wardNews ?? []);
    writer.writeList(obj.wardPersonnel ?? []);
  }
}

class WardInfo {
  final String id;
  int order;
  final String title;
  final String description;

  WardInfo({
    required this.id,
    required this.order,
    required this.title,
    required this.description,
  });

  factory WardInfo.fromJson(Map<String, dynamic> json) {
    return WardInfo(
      id: json['ward_infoID'] as String,
      order: json['order'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ward_infoID': id,
      'order': order,
      'title': title,
      'description': description,
    };
  }

  WardInfo copyWith({
    String? id,
    int? order,
    String? title,
    String? description,
  }) {
    return WardInfo(
      id: id ?? this.id,
      order: order ?? this.order,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}

class WardInfoAdapter extends TypeAdapter<WardInfo> {
  @override
  final int typeId = 9;

  @override
  WardInfo read(BinaryReader reader) {
    return WardInfo(
      id: reader.readString(),
      order: reader.readInt(),
      title: reader.readString(),
      description: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, WardInfo obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.order);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
  }
}

class WardNews {
  final String id;
  final String image;
  final String title;
  final String description;

  const WardNews({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
  });

  factory WardNews.fromJson(Map<String, dynamic> json) {
    return WardNews(
      id: json['ward_newsID'] as String,
      image: json['image'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'title': title,
      'description': description,
    };
  }
}

class WardNewsAdapter extends TypeAdapter<WardNews> {
  @override
  final int typeId = 10;

  @override
  WardNews read(BinaryReader reader) {
    return WardNews(
      id: reader.readString(),
      image: reader.readString(),
      title: reader.readString(),
      description: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, WardNews obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.image);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
  }
}

class WardPersonnel {
  final String id;
  final String image;
  final String name;
  final String position;
  final String phone;

  const WardPersonnel({
    required this.id,
    required this.image,
    required this.name,
    required this.position,
    required this.phone,
  });

  factory WardPersonnel.fromJson(Map<String, dynamic> json) {
    return WardPersonnel(
      id: json['ward_personnelID'] as String,
      image: json['image'] as String,
      name: json['name'] as String,
      position: json['position'] as String,
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'position': position,
      'phone': phone,
    };
  }

  WardPersonnel copyWith({
    String? id,
    String? image,
    String? name,
    String? position,
    String? phone,
  }) {
    return WardPersonnel(
      id: id ?? this.id,
      image: image ?? this.image,
      name: name ?? this.name,
      position: position ?? this.position,
      phone: phone ?? this.phone,
    );
  }
}

class WardPersonnelAdapter extends TypeAdapter<WardPersonnel> {
  @override
  final int typeId = 12;

  @override
  WardPersonnel read(BinaryReader reader) {
    return WardPersonnel(
      id: reader.readString(),
      image: reader.readString(),
      name: reader.readString(),
      position: reader.readString(),
      phone: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, WardPersonnel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.image);
    writer.writeString(obj.name);
    writer.writeString(obj.position);
    writer.writeString(obj.phone);
  }
}

class WardContent {
  final String id;
  final String name;
  final String type;
  final String source;
  final bool status;
  final int? displayTime;
  final DateTime startDate;
  final DateTime endDate;
  final String playType;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const WardContent({
    required this.id,
    required this.name,
    required this.type,
    required this.source,
    required this.status,
    this.displayTime,
    required this.startDate,
    required this.endDate,
    required this.playType,
    required this.startTime,
    required this.endTime,
  });

  factory WardContent.fromJson(Map<String, dynamic> json) {
    return WardContent(
      id: json['ward_fileID'],
      name: json['fileName'],
      type: json['fileType'],
      source: json['fileSource'],
      status: json['isActive'] ?? true,
      displayTime: json["ward_file_timer"]['displayTime'],
      startDate: DateTime.parse(json["ward_file_timer"]['startDate'] ?? "${DateTime.now().year}-01-01T00:00:00.000Z"),
      endDate: DateTime.parse(json["ward_file_timer"]['endDate'] ?? "${DateTime.now().year + 1}-01-01T00:00:00.000Z"),
      playType: json["ward_file_timer"]['type'],
      startTime: Utils.parseTimeOfDay(json["ward_file_timer"]['startTime'] ?? "00:00:00"),
      endTime: Utils.parseTimeOfDay(json["ward_file_timer"]['endTime'] ?? "23:59:59"),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ward_fileID': id,
      'fileName': name,
      'fileType': type,
      'fileSource': source,
      'isActive': status,
      'ward_file_timer': {
        'displayTime': displayTime,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'type': playType,
        'startTime': startTime.formatTimeOfDay,
        'endTime': endTime.formatTimeOfDay,
      },
    };
  }
}
