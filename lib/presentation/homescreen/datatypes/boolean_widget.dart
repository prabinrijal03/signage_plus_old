import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/device_layout.dart';

import '../cubit/layouts/layouts_cubit.dart';

class BooleanWidget extends StatelessWidget {
  final DeviceLayout layoutInfo;
  final int index;
  const BooleanWidget({super.key, required this.layoutInfo, required this.index});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LayoutsCubit, LayoutsState>(
      buildWhen: (previous, current) => true,
      builder: (context, state) {
        return Expanded(
          flex: layoutInfo.flex ?? 1,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                  (context.read<LayoutsCubit>().state as LayoutsLoaded).customUsers[index].condition
                      ? "assets/images/in.png"
                      : "assets/images/out.png",
                  height: 100),
            ),
          ),
        );
      },
    );
  }
}
