import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:slashplus/data/model/device_layout.dart';

class HeaderWidget extends StatelessWidget {
  final DeviceLayout layoutInfo;
  const HeaderWidget({super.key, required this.layoutInfo});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: layoutInfo.flex ?? 1,
      child: CachedNetworkImage(
        imageUrl: layoutInfo.data?.value ?? "",
        fit: BoxFit.fill,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }
}
