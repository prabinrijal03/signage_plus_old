import 'dart:convert';

enum DataTypes {
  content,
  ads,
  forex,
  forexFullscreen,
  scrollNews,
  nullType,
  weatherAndTime,
  image,
  text,
  boolean,
  header,
  ward,
  news,
  personnel,
  token,
  tokenButton,
  quiz,
  info
}

class DeviceLayoutInfo {
  final String id;
  final String name;
  final String orientation;
  final String type;
  final DeviceLayout json;

  DeviceLayoutInfo({
    required this.id,
    required this.name,
    required this.orientation,
    required this.type,
    required this.json,
  });

  factory DeviceLayoutInfo.fromJson(Map<String, dynamic> json) {
    DeviceLayout layoutJson;
    try {
      layoutJson = DeviceLayout.fromJson(json['layout']);
    } catch (e) {
      layoutJson = DeviceLayout.fromJson(jsonDecode(json['layout']));
    }

    return DeviceLayoutInfo(
      id: json['deviceLayoutID'],
      name: json['layoutName'],
      type: json['type'],
      orientation: json['orientation'],
      json: layoutJson,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceLayoutID': id,
      'layoutName': name,
      'orientation': orientation,
      'type': type,
      'layout': json.toJson(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class DeviceLayout {
  final String? id;
  final int? numberOfForex;
  final int? index;
  final String? type;
  final int? flex;
  final Data? data;
  final List<DeviceLayout>? children;

  DeviceLayout({
    this.id,
    this.numberOfForex,
    this.type,
    this.index,
    this.flex,
    this.data,
    this.children,
  });

  factory DeviceLayout.fromJson(Map<String, dynamic> json) {
    return DeviceLayout(
      id: json['id'],
      numberOfForex: json['numberOfForex'],
      type: json['type'],
      index: json['index'],
      flex: json['flex'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      children: json['children'] != null ? (json['children'] as List).map((i) => DeviceLayout.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numberOfForex': numberOfForex,
      'type': type,
      'index': index,
      'flex': flex,
      'data': data?.toJson(),
      'children': children?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class Data {
  final DataTypes? dataType;
  final int? fontSize;
  final bool? isBold;
  final bool? isItalic;
  final int? noOfForex;
  final String? value;

  const Data({this.dataType, this.noOfForex, this.fontSize, this.isBold, this.isItalic, this.value});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      dataType: DataTypes.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == json['dataType'].toString().toLowerCase(),
        orElse: () => DataTypes.nullType,
      ),
      noOfForex: json['noOfForex'],
      fontSize: json['fontSize'],
      isBold: json['isBold'],
      isItalic: json['isItalic'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dataType': dataType.toString().split('.').last,
      'noOfForex': noOfForex,
      'fontSize': fontSize,
      'isBold': isBold,
      'isItalic': isItalic,
      'value': value,
    };
  }

  bool get isNull => dataType == DataTypes.nullType;
}
