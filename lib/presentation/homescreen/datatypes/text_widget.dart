import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/device_layout.dart';

import '../cubit/layouts/layouts_cubit.dart';

class TextWidget extends StatelessWidget {
  final DeviceLayout layoutInfo;
  final int index;
  const TextWidget({super.key, required this.layoutInfo, required this.index});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: layoutInfo.flex ?? 1,
      child: Column(
        children: [
          if (layoutInfo.index == 0) const Spacer(),
          Container(
            padding: const EdgeInsets.only(left: 30, right: 17),
            width: double.maxFinite,
            child: AutoSizeText(
              layoutInfo.index == 0
                  ? (context.read<LayoutsCubit>().state as LayoutsLoaded).customUsers[index].name
                  : (context.read<LayoutsCubit>().state as LayoutsLoaded).customUsers[index].position,
              maxLines: layoutInfo.index == 0 ? 1 : 3,
              style: TextStyle(
                fontSize: layoutInfo.data?.fontSize?.toDouble() ?? 35,
                color: Colors.black,
                fontWeight: layoutInfo.data?.isBold ?? false ? FontWeight.bold : FontWeight.normal,
                fontStyle: layoutInfo.data?.isItalic ?? false ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
          if (layoutInfo.index == 1) const Spacer(),
        ],
      ),
    );
  }
}
