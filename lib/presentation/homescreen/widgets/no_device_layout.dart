import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../resources/constants.dart';
import '../cubit/layouts/layouts_cubit.dart';

class NoDeviceLayoutWidget extends StatelessWidget {
  final NoDeviceLayout state;
  const NoDeviceLayoutWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: AppConstants.deviceHeight,
      width: AppConstants.deviceWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset("assets/images/no_device_layout.svg", fit: BoxFit.contain, height: AppConstants.deviceHeight * 0.3),
          Divider(
            height: 20,
            thickness: 1,
            endIndent: AppConstants.deviceWidth * 0.35,
            indent: AppConstants.deviceWidth * 0.35,
          ),
          SizedBox(height: AppConstants.deviceHeight * 0.02),
          Text(
            "We are unable to find device layout.\nPlease enable device layout to run digital signage system.\nThank you !\n\nDevice Name: ${state.deviceName}",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
