import 'package:flutter/material.dart';

import '../../../data/model/device_layout.dart';
import '../../../resources/color_manager.dart';
import '../../../resources/constants.dart';

class InfoWidget extends StatelessWidget {
  final DeviceLayout layoutInfo;
  const InfoWidget({super.key, required this.layoutInfo});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: layoutInfo.flex ?? 1,
      child: Container(
        color: ColorManager.primary,
        padding: const EdgeInsets.all(12),
        width: double.maxFinite,
        child: Row(
          children: [
            const SizedBox(width: 10),
            const Text("For more information",
                style: TextStyle(
                  fontSize: 53,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            const Spacer(),
            Image.asset(
              "assets/images/qr.png",
              height: AppConstants.deviceHeight * 0.3,
            ),
          ],
        ),
      ),
    );
  }
}
