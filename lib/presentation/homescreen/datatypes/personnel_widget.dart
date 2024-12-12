import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/model/ward_settings.dart';

import '../../../data/model/device_layout.dart';
import '../bloc/wards_personnel/wards_personnel_bloc.dart';
import '../widgets/auto_scroll_personnel.dart';

class PersonnelWidget extends StatelessWidget {
  final DeviceLayout layoutInfo;
  final WardSettings? wardSettings;
  const PersonnelWidget({super.key, required this.layoutInfo, this.wardSettings});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WardsPersonnelBloc, WardsPersonnelState>(
      builder: (context, state) {
        debugPrint("""
                        Wards Personnel Rebuilding
                        _________________________
          """);
        if (state is WardsPersonnelLoaded) {
          final wardPersonnel = state.wardPersonnel;
          if (wardPersonnel.isEmpty) {
            return Expanded(
                flex: layoutInfo.flex ?? 1,
                child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Center(child: Text("No Personnel", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))));
          }
          return AutoScrollPersonnel(
            flex: layoutInfo.flex ?? 1,
            wardPersonnel: wardPersonnel,
            displaySeconds: wardSettings?.wardPersonnelDisplayTime ?? 120,
          );
        }

        if (state is WardsPersonnelError) {
          return Expanded(
              flex: layoutInfo.flex ?? 1,
              child: Center(child: Text(state.message, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))));
        }
        return Expanded(
            flex: layoutInfo.flex ?? 1,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: const SizedBox.expand(),
            ));
      },
    );
  }
}
