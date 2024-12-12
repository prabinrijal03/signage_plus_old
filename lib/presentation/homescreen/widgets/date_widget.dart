import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../../core/extensions.dart';
import '../../../resources/constants.dart';

class DateWidget extends StatelessWidget {
  final Stream<DateTime> dateTimeStream;
  final TextStyle textStyle;
  final String language;
  final String format;
  const DateWidget({
    super.key,
    required this.dateTimeStream,
    required this.textStyle,
    required this.language,
    required this.format,
  });
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: dateTimeStream,
      builder: (context, snapshot) {
        final currentDateTime = snapshot.data ?? AppConstants.now;
        return AutoSizeText(language == "np" ? currentDateTime.inNepali : currentDateTime.getformatDateTime(format), style: textStyle, maxLines: 1);
      },
    );
  }
}
