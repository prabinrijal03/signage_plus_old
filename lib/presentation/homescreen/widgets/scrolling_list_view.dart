import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marquee_vertical/marquee_vertical.dart';

import '../../../data/model/device_layout.dart';
import '../../../resources/constants.dart';
import '../cubit/layouts/layouts_cubit.dart';

class ScrollingListView extends StatefulWidget {
  final EdgeInsetsGeometry padding;
  final Widget Function(BuildContext, DeviceLayout, {int? index}) builder;
  final DeviceLayout layout;
  final int stopDuration;
  const ScrollingListView({super.key, required this.padding, required this.stopDuration, required this.builder, required this.layout});

  @override
  State<ScrollingListView> createState() => ScrollingListViewState();
}

class ScrollingListViewState extends State<ScrollingListView> {
  @override
  Widget build(BuildContext context) {
    final int length = (context.read<LayoutsCubit>().state as LayoutsLoaded).customUsers.length;
    if (length == 0) {
      return Container(
        color: Colors.black,
        padding: widget.padding,
        height: double.maxFinite,
        child: const Center(
          child: Text(
            'No Doctors Found. Please add a doctor to your list.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    return Container(
      color: Colors.black,
      padding: widget.padding,
      height: double.maxFinite,
      child: MarqueeVertical(
        stopDuration: Duration(seconds: widget.stopDuration),
        lineHeight: (AppConstants.deviceHeight - 15) / 6,
        marqueeLine: 6,
        itemBuilder: (index) {
          return IndividualUserTile(widget: widget, index: index);
        },
        itemCount: length,
      ),
    );
  }
}

class IndividualUserTile extends StatelessWidget {
  const IndividualUserTile({
    super.key,
    required this.widget,
    required this.index,
  });

  final ScrollingListView widget;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7.5),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), color: Colors.white),
      height: (AppConstants.deviceHeight - 15) / 6,
      child: Column(
        children: [
          widget.builder(
            context,
            widget.layout,
            index: index,
          ),
        ],
      ),
    );
  }
}
