import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/device_layout.dart';
import '../bloc/feedback/feedback_cubit.dart';
import '../cubit/layouts/layouts_cubit.dart';
import '../../../resources/constants.dart';
import '../../../resources/transition_manager.dart';
import '../bloc/contents/contents_bloc.dart';

class ContentWidget extends StatelessWidget {
  final FeedbackCubit feedbackCubit;
  final DeviceLayout layoutInfo;
  final Function getContentWidget;
  final bool showFrontSide;
  const ContentWidget(
      {super.key,
      required this.layoutInfo,
      required this.getContentWidget,
      required this.showFrontSide,
      required this.feedbackCubit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContentsBloc, ContentsState>(
        buildWhen: (previous, current) {
      if (!feedbackCubit.showFrontSide) {
        return false;
      }
      return true;
    }, builder: ((context, state) {
      debugPrint("""
                            Content Rebuilding
                            __________________
              """);
      if (state is LoadedContents && state.content.isFullscreenContent) {
        return SizedBox(
            height: AppConstants.deviceHeight -
                context.read<LayoutsCubit>().padding.vertical,
            width: AppConstants.deviceWidth -
                context.read<LayoutsCubit>().padding.horizontal,
            child: Column(
              children: [
                Expanded(
                  flex: layoutInfo.flex ?? 1,
                  child: RepaintBoundary(
                      child: AnimatedSwitcher(
                    duration: const Duration(seconds: 1),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      TransitionType? transitionType;
                      transitionType =
                          TransitionType.fromTitle(state.content.transition) ??
                              TransitionType.fade;
                      return TransitionManager(
                              child: child, animation: animation)
                          .applyTransition(transitionType);
                    },
                    child: Column(
                      key: UniqueKey(),
                      children: [
                        getContentWidget(
                            context, layoutInfo, state, showFrontSide)
                      ],
                    ),
                  )),
                ),
              ],
            ));
      }
      return Expanded(
        flex: layoutInfo.flex ?? 1,
        child: RepaintBoundary(
          child: AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            transitionBuilder: (Widget child, Animation<double> animation) {
              TransitionType? transitionType;
              if (state is LoadedContents) {
                transitionType =
                    TransitionType.fromTitle(state.content.transition) ??
                        TransitionType.fade;
              }
              return TransitionManager(child: child, animation: animation)
                  .applyTransition(transitionType);
            },
            child: Column(
              key: UniqueKey(),
              children: [
                getContentWidget(context, layoutInfo, state, showFrontSide)
              ],
            ),
          ),
        ),
      );
    }));
  }
}
