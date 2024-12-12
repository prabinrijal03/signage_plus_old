import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:slashplus/data/model/device_layout.dart';

import '../../../data/model/ward_settings.dart';
import '../bloc/wards_info/wards_info_bloc.dart';
import '../widgets/ward_widget.dart';

class WardsWidget extends StatelessWidget {
  final DeviceLayout layoutInfo;
  final WardSettings? wardSettings;
  const WardsWidget({super.key, required this.layoutInfo, this.wardSettings});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WardsInfoBloc, WardsInfoState>(builder: (context, state) {
      debugPrint("""
                        Wards Info Rebuilding
                        _________________________
          """);
      if (state is WardsInfoLoaded) {
        final wardInfo = state.wardInfo;
        if (wardInfo.isEmpty) {
          return Expanded(
              flex: layoutInfo.flex ?? 1,
              child: const Center(child: Text("No Citizen Charter", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))));
        }
        wardInfo.sort((a, b) => a.order.compareTo(b.order));
        return WardWidget(
          wardInfo: wardInfo,
          wardContent: state.wardContent,
          seconds: wardSettings?.wardInfoDisplayTime ?? 120,
          flex: layoutInfo.flex ?? 1,
          scrollSpeed: wardSettings?.wardInfoScrollSpeed ?? 10,
        );
      }

      if (state is WardsInfoError) {
        return Expanded(
            flex: layoutInfo.flex ?? 1, child: Center(child: Text(state.message, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))));
      }

      return Expanded(
          flex: layoutInfo.flex ?? 1,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: const SizedBox.expand(),
          ));
    });
  }
}
