import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/extensions.dart';
import '../../../data/model/device_layout.dart';

import '../../../resources/color_manager.dart';
import '../../../resources/constants.dart';
import '../bloc/scrolling_text/scrolling_text_bloc.dart';
import '../widgets/scrolling_text_widget.dart';

class ScrollNewsWidget extends StatelessWidget {
  final DeviceLayout layoutInfo;
  const ScrollNewsWidget({super.key, required this.layoutInfo});

  @override
  Widget build(BuildContext context) {
    debugPrint("""
                        Scroll News Rebuilding
                        __________________
          """);
    return BlocBuilder<ScrollingTextBloc, ScrollingTextState>(builder: ((context, state) {
      if (state is LoadedScrollingText) {
        return ScrollingTextWidget(
          flex: layoutInfo.flex ?? 1,
          backgroundColor: state.scrollText.scrollCategory.backgroundColor.toColor,
          categoryText: state.scrollText.scrollCategory.category,
          scrollText: state.scrollText.text,
        );
      } else if (state is EmptyScrollingText) {
        return ScrollingTextWidget(
            backgroundColor: ColorManager.secondary,
            categoryText: "No Content",
            scrollText: AppConstants.emptyScrollText,
            flex: layoutInfo.flex ?? 1);
      } else {
        return Expanded(
          flex: layoutInfo.flex ?? 1,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
            ),
          ),
        );
      }
    }));
  }
}
