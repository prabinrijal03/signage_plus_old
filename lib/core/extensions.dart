import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';

import '../services/hive_services.dart';
import '../services/utils.dart';

extension TimeOfDayExtension on TimeOfDay {
  String get formatTimeOfDay => "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";

  bool isAfter(DateTime dateTime) {
    final now = HiveService().getStoredDateTime() ?? DateTime.now();
    final time = DateTime(now.year, now.month, now.day, hour, minute);
    return time.isAfter(dateTime);
  }

  bool isBefore(DateTime dateTime) {
    final now = HiveService().getStoredDateTime() ?? DateTime.now();
    final time = DateTime(now.year, now.month, now.day, hour, minute);
    return time.isBefore(dateTime);
  }
}

extension DateTimeExtension on DateTime {
  static final Map<String, String> englishToNepaliWeekDays = {
    "Sunday": "आइतबार",
    "Monday": "सोमबार",
    "Tuesday": "मंगलबार",
    "Wednesday": "बुधबार",
    "Thursday": "बिहिबार",
    "Friday": "शुक्रबार",
    "Saturday": "शनिबार",
  };

  static final Map<int, String> englishToNepaliMonths = {
    1: "बैशाख",
    2: "जेठ",
    3: "असार",
    4: "साउन",
    5: "भदौ",
    6: "असोज",
    7: "कार्तिक",
    8: "मंसिर",
    9: "पुष",
    10: "माघ",
    11: "फाल्गुन",
    12: "चैत्र",
  };

  String getNepaliFormattedDate() {
    final nepaliDate = Utils.convertToNepaliNumbers(day).padLeft(2, "०");
    final nepaliMonth = englishToNepaliMonths[month]!;
    final nepaliYear = Utils.convertToNepaliNumbers(year).padLeft(4, "०");

    return "$nepaliDate $nepaliMonth $nepaliYear";
  }

  String getformatDateTime(String format) => DateFormat(format).format(this);

  String get inNepali {
    final hr = hour % 12 == 0 ? 12 : hour % 12;
    final nepaliWeekDay = englishToNepaliWeekDays[DateFormat('EEEE').format(this)]!;
    final nepaliTime =
        '${Utils.convertToNepaliNumbers(hr).padLeft(2, "०")}:${Utils.convertToNepaliNumbers(minute).padLeft(2, "०")}:${Utils.convertToNepaliNumbers(second).padLeft(2, "०")} ${hour > 12 ? 'PM' : 'AM'}';
    final nepaliMonth = englishToNepaliMonths[toNepaliDateTime().month]!;
    final nepaliDate = Utils.convertToNepaliNumbers(toNepaliDateTime().day).padLeft(2, "०");
    final nepaliYear = Utils.convertToNepaliNumbers(toNepaliDateTime().year).padLeft(4, "०");

    return "$nepaliWeekDay, $nepaliDate $nepaliMonth $nepaliYear | $nepaliTime";
  }
}

extension ColorExt on String {
  Color get toColor {
    final hexCode = replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}

extension StringExtension on String {
  String get capitalize => "${this[0].toUpperCase()}${substring(1)}";

  EdgeInsetsGeometry get toEdgeInsets {
    final values = split(',').map((e) => double.parse(e)).toList();
    return EdgeInsets.fromLTRB(values[3], values[0], values[1], values[2]);
  }

  DateTime toDateTime(String inputFormat) {
    DateFormat format = DateFormat(inputFormat);
    DateTime parsedDatetime = format.parse(this);
    return parsedDatetime;
  }
}
