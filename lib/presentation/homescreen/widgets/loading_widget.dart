import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../resources/color_manager.dart';
import '../../../resources/constants.dart';

class LoadingWidget extends StatelessWidget {
  final String title;
  final double imageHeight;
  const LoadingWidget({super.key, required this.title, this.imageHeight = 0.3});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: AppConstants.deviceHeight,
        width: AppConstants.deviceWidth,
        decoration: BoxDecoration(
          color: ColorManager.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Spacer(),
          SvgPicture.asset(
            "assets/images/logo.svg",
            height: AppConstants.deviceHeight * imageHeight,
          ),
          SizedBox(height: AppConstants.deviceHeight * 0.05),
          const CircularProgressIndicator(
            color: ColorManager.secondary,
          ),
          SizedBox(height: AppConstants.deviceHeight * 0.05),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: AppConstants.deviceHeight * 0.005),
          // const DownloadProgressText(),
          // SizedBox(height: AppConstants.deviceHeight * 0.005),
          const Spacer(),
          const Text("from", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black)),
          SizedBox(height: AppConstants.deviceHeight * 0.005),
          SvgPicture.asset('assets/images/slashplus.svg', height: AppConstants.deviceHeight * 0.04),
          SizedBox(height: AppConstants.deviceHeight * 0.03),
        ]));
  }
}
