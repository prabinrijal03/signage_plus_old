import 'package:flutter/material.dart';

import '../../../data/model/ward_details.dart';
import '../../../resources/color_manager.dart';
import '../../../resources/constants.dart';
import '../../../services/utils.dart';
import 'auto_scroll_html_widget.dart';

class WardIndividualCard extends StatelessWidget {
  final int flex;
  final WardInfo wardInfo;
  final int scrollSpeed;
  const WardIndividualCard({super.key, required this.wardInfo, required this.flex, required this.scrollSpeed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: ColorManager.grey,
          border: Border.all(color: Colors.grey),
        ),
        height: AppConstants.deviceHeight * 0.3,
        width: AppConstants.deviceWidth / 2,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  ("${Utils.convertToNepaliNumbers(wardInfo.order)}) ${wardInfo.title}"),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColorManager.errorRed),
                ),
              ),
              AutoScrollHtmlWidget(
                html: wardInfo.description,
                key: UniqueKey(),
                scrollSpeed: scrollSpeed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
