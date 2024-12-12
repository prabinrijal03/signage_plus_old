import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:slashplus/services/hive_services.dart';
import '../resources/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class TokenService {
  final Dio counterDio;
  static final TokenService _singleton = TokenService._internal(
      counterDio: Dio(BaseOptions(
          headers: {'x-device-code': HiveService.getTokenDeviceCode()})));

  factory TokenService() {
    return _singleton;
  }

  TokenService._internal({required this.counterDio});

  io.Socket? socket;
  Counters? _counters;
  Issuers? _issuers;

  Counters get counters => _singleton._counters ?? const Counters(counters: []);
  int get counterLength => _singleton._counters?.counters.length ?? 0;

  Issuers get issuers => _singleton._issuers ?? const Issuers(issuers: []);
  int get issuerLength => _singleton._issuers?.issuers.length ?? 0;

  // Counter Controller
  final StreamController<Counter> _counterController =
      StreamController<Counter>.broadcast();
  Stream<Counter> get counterStream => _counterController.stream;

  final StreamController<int> _deleteCounterController =
      StreamController<int>.broadcast();
  Stream<int> get deleteCounterStream => _deleteCounterController.stream;

  Future<void> dispose() async {
    socket?.offAny();
  }

  Future<Counters?> getCounters() async {
    final result = await counterDio.get(UrlConstants.getCounters);
    final statusCode = result.statusCode ?? 500;
    if (statusCode >= 500) {
      throw Exception('Server Error! Please try again later.');
    }

    if (statusCode != 200) {
      throw Exception(
          result.data['message'] ?? 'Something went wrong! Please try again.');
    }
    _counters = Counters.fromJson(result.data['data']);
    return _counters;
  }

  Future<Issuers?> getIssuers() async {
    final result = await counterDio.get(UrlConstants.getIssuers);
    final statusCode = result.statusCode ?? 500;
    if (statusCode >= 500) {
      throw Exception('Server Error! Please try again later.');
    }

    if (statusCode != 200) {
      throw Exception(
          result.data['message'] ?? 'Something went wrong! Please try again.');
    }

    _issuers = Issuers.fromJson(result.data['data']);

    return Issuers.fromJson(result.data['data']);
  }

  Future<void> connectDisplaySocket(String userId, String type) async {
    try {
      socket = io.io(
        UrlConstants.tokenSocketUrl,
        io.OptionBuilder().setTransports(['websocket']).setAuth(
            {"x-device-code": HiveService.getTokenDeviceCode()}).build(),
      );

      socket?.onConnect((data) {
        debugPrint("CONNECTED TO SOCKET (TOKEN DISPLAY):: $data");

        socket?.onError((data) {
          debugPrint("Error::: $data");
        });

        socket?.onConnectError((data) {
          debugPrint("on Connect Error::: $data");
        });
/* 
        socket?.onConnectTimeout((data) {
          debugPrint('on Connect Timeout::: $data');
        }); */

        socket?.on('next-token', (data) {
          if (data == null) return;
          final counter = Counter.fromJson(data);
          _counterController.add(counter);
        });

        socket?.on('end-service', (data) {
          print(data);
          _deleteCounterController.add(0);
        });
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> connectButtonSocket(String userId, String type) async {
    try {
      final issuers = await getIssuers();
      socket = io.io(
        UrlConstants.tokenSocketUrl,
        io.OptionBuilder().setTransports(['websocket']).setQuery({
          "userId": userId,
          "type": type,
          "issuers": getIssuersId(issuers),
        }).build(),
      );
      socket!.onConnect((data) {
        debugPrint("CONNECTED TO SOCKET (TOKEN BUTTON):: $data");
      });
    } catch (e) {
      rethrow;
    }
  }

  List<int> getCountersId(Counters? counters) {
    if (counters == null) {
      return [];
    }
    List<int> counterIds = [];
    for (Counter element in counters.counters) {
      counterIds.add(element.id);
    }
    return counterIds;
  }

  List<String> getIssuersId(Issuers? issuers) {
    if (issuers == null) {
      return [];
    }
    List<String> issuersId = [];
    for (Issuer element in issuers.issuers) {
      issuersId.add(element.id);
    }
    return issuersId;
  }
}

class Counters extends Equatable {
  final List<Counter> counters;

  const Counters({required this.counters});

  factory Counters.fromJson(List<dynamic> json) {
    return Counters(counters: json.map((e) => Counter.fromJson(e)).toList());
  }

  Map<String, dynamic> toJson() {
    return {'counters': counters.map((e) => e.toJson()).toList()};
  }

  Counters copyWith({List<Counter>? counters}) {
    return Counters(counters: counters ?? this.counters);
  }

  @override
  List<Object?> get props => [counters];
}

class Counter extends Equatable {
  final int id;
  final String applicationId;
  final String applicantName;
  final int number;
  final DateTime issuedAt;
  final DateTime prioritizeAfter;
  final int serviceId;
  final bool skipped;
  final DateTime? serviceStartedAt;
  final DateTime? serviceEndedAt;
  final int? serverId;
  final int? operatorId;

  const Counter({
    required this.id,
    required this.applicationId,
    required this.applicantName,
    required this.number,
    required this.issuedAt,
    required this.prioritizeAfter,
    required this.serviceId,
    required this.skipped,
    this.serviceStartedAt,
    this.serviceEndedAt,
    this.serverId,
    this.operatorId,
  });

  factory Counter.fromJson(Map<String, dynamic> json) {
    return Counter(
        id: json['id'],
        applicationId: json['applicationId'],
        applicantName: json['applicantName'],
        number: json['number'],
        issuedAt: DateTime.parse(json['issuedAt']),
        prioritizeAfter: DateTime.parse(json['prioritizeAfter']),
        serviceId: json['serviceId'],
        skipped: json['skipped'],
        serviceStartedAt: json['serviceStartedAt'] == null
            ? null
            : DateTime.parse(json['serviceStartedAt']),
        serviceEndedAt: json['serviceEndedAt'] == null
            ? null
            : DateTime.parse(json['serviceEndedAt']),
        serverId: json['serverId'],
        operatorId: json['operatorId']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicationId': applicationId,
      'applicantName': applicantName,
      'number': number,
      'issuedAt': issuedAt.toIso8601String(),
      'prioritizeAfter': prioritizeAfter.toIso8601String(),
      'serviceId': serviceId,
      'skipped': skipped,
      'serviceStartedAt': serviceStartedAt?.toIso8601String(),
      'serviceEndedAt': serviceEndedAt?.toIso8601String(),
      'serverId': serverId,
      'operatorId': operatorId
    };
  }

  Counter copyWith({
    int? id,
    String? applicationId,
    String? applicantName,
    int? number,
    DateTime? issuedAt,
    DateTime? prioritizeAfter,
    int? serviceId,
    bool? skipped,
    DateTime? serviceStartedAt,
    DateTime? serviceEndedAt,
    int? serverId,
    int? operatorId,
  }) {
    return Counter(
        id: id ?? this.id,
        applicationId: applicationId ?? this.applicationId,
        applicantName: applicantName ?? this.applicantName,
        number: number ?? this.number,
        issuedAt: issuedAt ?? this.issuedAt,
        prioritizeAfter: prioritizeAfter ?? this.prioritizeAfter,
        serviceId: serviceId ?? this.serviceId,
        skipped: skipped ?? this.skipped,
        serviceStartedAt: serviceStartedAt ?? this.serviceStartedAt,
        serviceEndedAt: serviceEndedAt ?? this.serviceEndedAt,
        serverId: serverId ?? this.serverId,
        operatorId: operatorId ?? this.operatorId);
  }

  @override
  List<Object?> get props => [
        id,
        applicationId,
        applicantName,
        number,
        issuedAt,
        prioritizeAfter,
        serviceId,
        skipped,
        serviceStartedAt,
        serviceEndedAt,
        serverId,
        operatorId
      ];
}

class CounterSettings extends Equatable {
  final String tokenBackgroundColor;
  final String tokenLabelColor;
  final String tokenNumberColor;
  final String nameBackgroundColor;
  final String nameLabelColor;
  const CounterSettings(
      {required this.tokenBackgroundColor,
      required this.tokenLabelColor,
      required this.tokenNumberColor,
      required this.nameBackgroundColor,
      required this.nameLabelColor});

  factory CounterSettings.fromJson(Map<String, dynamic> json) {
    return CounterSettings(
        tokenBackgroundColor: json['tokenBackgroundColor'],
        tokenLabelColor: json['tokenLabelColor'],
        tokenNumberColor: json['tokenNumberColor'],
        nameBackgroundColor: json['nameBackgroundColor'],
        nameLabelColor: json['nameLabelColor']);
  }

  Map<String, dynamic> toJson() {
    return {
      'tokenBackgroundColor': tokenBackgroundColor,
      'tokenLabelColor': tokenLabelColor,
      'tokenNumberColor': tokenNumberColor,
      'nameBackgroundColor': nameBackgroundColor,
      'nameeabelColor': nameLabelColor
    };
  }

  @override
  List<Object?> get props => [
        tokenBackgroundColor,
        tokenLabelColor,
        tokenNumberColor,
        nameBackgroundColor,
        nameLabelColor
      ];
}

class Issuers extends Equatable {
  final List<Issuer> issuers;

  const Issuers({required this.issuers});

  factory Issuers.fromJson(List<dynamic> json) {
    return Issuers(issuers: json.map((e) => Issuer.fromJson(e)).toList());
  }

  Map<String, dynamic> toJson() {
    return {'issuers': issuers.map((e) => e.toJson()).toList()};
  }

  Issuers copyWith({List<Issuer>? issuers}) {
    return Issuers(
      issuers: issuers ?? this.issuers,
    );
  }

  @override
  List<Object?> get props => [issuers];
}

class Issuer extends Equatable {
  final String id;
  final String? name;
  final int count;
  final int current;
  final IssuerSetting? settings;

  const Issuer(
      {required this.id,
      this.name,
      required this.count,
      required this.current,
      required this.settings});

  factory Issuer.fromJson(Map<String, dynamic> json) {
    return Issuer(
        id: json['id'],
        name: json['name'],
        count: json['count'],
        current: json['current'],
        settings: json['settings'] == null
            ? null
            : IssuerSetting.fromJson(json['settings']));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'Count': count,
      'current': current,
      'settings': settings
    };
  }

  Issuer copyWith(
      {String? id,
      String? name,
      int? count,
      int? current,
      IssuerSetting? settings}) {
    return Issuer(
        id: id ?? this.id,
        name: name ?? this.name,
        count: count ?? this.count,
        current: current ?? this.current,
        settings: settings ?? this.settings);
  }

  @override
  List<Object?> get props => [id, name, count, current, settings];
}

class IssuerSetting extends Equatable {
  final String textColor;
  final String backgroundColor;

  const IssuerSetting({required this.textColor, required this.backgroundColor});

  factory IssuerSetting.fromJson(Map<String, dynamic> json) {
    return IssuerSetting(
        textColor: json['textColor'], backgroundColor: json['backgroundColor']);
  }

  Map<String, dynamic> toJson() {
    return {'textColor': textColor, 'backgroundColor': backgroundColor};
  }

  @override
  List<Object?> get props => [textColor, backgroundColor];
}
