import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../../services/token_services.dart';
import '../../../resources/color_manager.dart';
import '../../../resources/constants.dart';

enum TtsState { playing, stopped, paused, continued }

class TokenViewer extends StatelessWidget {
  final Counter counter;
  const TokenViewer({super.key, required this.counter});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(32),
        ),
        width: double.maxFinite,
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(6),
                width: AppConstants.deviceWidth,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Text(
                  'Counter ${counter.serverId}',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: ColorManager.white),
                  textAlign: TextAlign.center,
                )),
            const Divider(color: ColorManager.white, thickness: 1.2, height: 1),
            const Spacer(),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (counter.number == -1) ...[
                const Text(
                  "On Break",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: ColorManager.white),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Text(counter.applicantName, style: const TextStyle(color: ColorManager.white)),
                const SizedBox(height: 5),
                AutoSizeText(counter.number.toString(),
                    minFontSize: 90, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, height: 1), maxLines: 1),
              ],
            ]),
            const Spacer(),
          ],
        ));
  }
}
