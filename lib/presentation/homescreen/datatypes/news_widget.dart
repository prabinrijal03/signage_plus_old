import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/model/device_layout.dart';

import '../../../data/model/ward_settings.dart';
import '../bloc/wards_news/wards_news_bloc.dart';
import '../widgets/auto_scroll_ward_news.dart';

class NewsWidget extends StatelessWidget {
  final DeviceLayout layoutInfo;
  final WardSettings? wardSettings;
  const NewsWidget({super.key, required this.layoutInfo, this.wardSettings});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WardsNewsBloc, WardsNewsState>(
      builder: (context, state) {
        debugPrint("""
                        Wards News Rebuilding
                        _________________________
          """);
        if (state is WardsNewsLoaded) {
          final wardNews = state.wardNews;
          if (wardNews.isEmpty) {
            return Expanded(
                flex: layoutInfo.flex ?? 1,
                child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Center(child: Text("No News", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))));
          }
          return AutoScrollPage(
            flex: layoutInfo.flex ?? 1,
            wardNews: wardNews,
            displaySeconds: wardSettings?.wardNewsDisplayTime ?? 120,
            scrollSpeed: wardSettings?.wardNewsScrollSpeed ?? 10,
          );
        }

        if (state is WardsNewsError) {
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
