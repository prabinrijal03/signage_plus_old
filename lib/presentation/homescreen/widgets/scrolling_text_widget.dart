import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrolling_text/scrolling_text.dart';

import '../../../resources/color_manager.dart';
import '../../../resources/constants.dart';
import '../bloc/scrolling_text/scrolling_text_bloc.dart';

class ScrollingTextWidget extends StatelessWidget {
  final Color backgroundColor;
  final String categoryText;
  final String scrollText;
  final int flex;

  const ScrollingTextWidget({
    super.key,
    required this.backgroundColor,
    required this.categoryText,
    required this.scrollText,
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        width: AppConstants.deviceWidth,
        color: ColorManager.black,
        child: Row(
          children: [
            Container(
              constraints: BoxConstraints(
                  minWidth: AppConstants.deviceWidth * flex / 50),
              padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.deviceWidth * flex / 50),
              alignment: Alignment.center,
              color: backgroundColor,
              height: double.maxFinite,
              child: Text(categoryText,
                  style: TextStyle(
                      fontSize: flex * 25,
                      color: backgroundColor == Colors.white
                          ? Colors.black
                          : Colors.white)),
            ),
            Flexible(
              child: ScrollingText(
                text: scrollText,
                textStyle: TextStyle(fontSize: flex * 25, color: Colors.white),
                speed: 60,
                startOffset: AppConstants.deviceWidth * (flex * 0.9),
                endOffset: AppConstants.deviceWidth * (flex * 0.9),
                onFinish: () {
                  context
                      .read<ScrollingTextBloc>()
                      .add(const ChangeScrollingText());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
