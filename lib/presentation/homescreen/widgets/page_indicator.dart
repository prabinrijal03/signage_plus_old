import 'package:flutter/material.dart';

import '../../../resources/color_manager.dart';
import '../../../resources/constants.dart';

class PageIndicator extends StatelessWidget {
  final int itemCount;
  final int currentPage;
  final Color? selectedColor;
  final Color? unselectedColor;

  const PageIndicator({
    super.key,
    required this.itemCount,
    required this.currentPage,
    this.selectedColor = ColorManager.darkBlue,
    this.unselectedColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppConstants.deviceHeight * 0.02,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(itemCount, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 0.5,
                ),
              ),
              child: CircleAvatar(
                radius: 3,
                backgroundColor: currentPage == index ? selectedColor : unselectedColor,
              ),
            ),
          );
        }),
      ),
    );
  }
}
