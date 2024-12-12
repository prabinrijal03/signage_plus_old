import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/model/device_layout.dart';

import '../../../core/network/cubit/network_cubit.dart';
import '../../../resources/constants.dart';
import '../bloc/information/information_bloc.dart';
import '../widgets/date_widget.dart';
import '../widgets/weather_widget.dart';

class WeatherAndTimeWidget extends StatelessWidget {
  final DeviceLayout layoutInfo;
  const WeatherAndTimeWidget({super.key, required this.layoutInfo});

  @override
  Widget build(BuildContext context) {
    debugPrint("""
                        Weather and Time Rebuilding
                        __________________
          """);
    return BlocBuilder<InformationBloc, InformationState>(
      builder: (context, state) {
        if (state is InformationLoading) {
          return Expanded(
              flex: layoutInfo.flex ?? 1,
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: const SizedBox.expand(),
              ));
        }
        if (state is InformationLoaded) {
          final flex = layoutInfo.flex ?? 1;
          final textStyle = TextStyle(
              fontSize: (flex * 25),
              color: state.primaryColor,
              fontWeight: FontWeight.w500);

          return Expanded(
              flex: flex,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: flex * 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        width: AppConstants.deviceWidth * 0.35,
                        child: state.displayDate
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: DateWidget(
                                  dateTimeStream: context
                                      .read<NetworkCubit>()
                                      .dateTimeStream,
                                  language: state.language,
                                  textStyle: textStyle,
                                  format: state.dateFormat,
                                ),
                              )
                            : const SizedBox.shrink()),
                    SizedBox(
                      child: state.displayWeather
                          ? Center(
                              child: WeatherWidget(
                                  lat: double.parse(
                                      state.location.split(",").first),
                                  long: double.parse(
                                      state.location.split(",").last),
                                  language: state.language,
                                  textStyle: textStyle),
                            )
                          : const SizedBox.shrink(),
                    ),
                    SizedBox(
                      width: AppConstants.deviceWidth * 0.25,
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: state.displayDeviceName
                              ? AutoSizeText(state.deviceName,
                                  style: textStyle, maxLines: 1)
                              : const SizedBox.shrink()),
                    ),
                  ],
                ),
              ));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
