import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/device_layout.dart';
import '../cubit/layouts/layouts_cubit.dart';

class ImageWidget extends StatelessWidget {
  final DeviceLayout layoutInfo;
  final int index;
  const ImageWidget({super.key, required this.layoutInfo, required this.index});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: layoutInfo.flex ?? 1,
      child: Container(
        clipBehavior: Clip.none,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: CachedNetworkImage(
          imageUrl: (context.read<LayoutsCubit>().state as LayoutsLoaded).customUsers[index].image,
          fit: BoxFit.cover,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }
}
