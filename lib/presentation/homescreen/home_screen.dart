import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:screenshot/screenshot.dart';
import 'package:slashplus/presentation/homescreen/bloc/feedback/feedback_cubit.dart';
import 'package:wifi_iot/wifi_iot.dart';

import '../../core/dependency_injection.dart';
import '../../core/network/cubit/network_cubit.dart';
import '../../data/model/contents.dart';
import '../../data/model/device_layout.dart';
import '../../data/model/devices.dart';
import '../../data/model/version.dart';
import '../../data/model/ward_settings.dart';
import '../../data/usecases/check_device_id.dart' as c;
import '../../data/usecases/fetch_condition.dart';
import '../../data/usecases/fetch_ward_info.dart' as w;
import '../../resources/color_manager.dart';
import '../../resources/constants.dart';
import '../../services/hive_services.dart';
import '../../services/log_services.dart';
import '../../services/socket_services.dart';
import '../../services/utils.dart';
import 'bloc/contents/contents_bloc.dart';
import 'bloc/information/information_bloc.dart';
import 'bloc/scrolling_text/scrolling_text_bloc.dart' as stb;
import 'bloc/token/token_bloc.dart';
import 'bloc/wards_info/wards_info_bloc.dart';
import 'bloc/wards_news/wards_news_bloc.dart';
import 'bloc/wards_personnel/wards_personnel_bloc.dart';
import 'cubit/layouts/layouts_cubit.dart';
import 'cubit/quiz/quiz_cubit.dart';
import 'cubit/settings/setting_cubit.dart';
import 'datatypes/boolean_widget.dart';
import 'datatypes/content_widget.dart';
import 'datatypes/header_widget.dart';
import 'datatypes/image_widget.dart';
import 'datatypes/info_widget.dart';
import 'datatypes/news_widget.dart';
import 'datatypes/personnel_widget.dart';
import 'datatypes/quiz_widget.dart';
import 'datatypes/scroll_new_widget.dart';
import 'datatypes/text_widget.dart';
import 'datatypes/token_button_widget.dart';
import 'datatypes/token_widget.dart';
import 'datatypes/wards_widget.dart';
import 'datatypes/weather_and_time_widget.dart';
import 'widgets/auto_scroll_html_widget.dart';
import 'widgets/device_inactive.dart';
// import 'widgets/flip_feedback_widget.dart';
import 'widgets/link_preview_widget.dart';
import 'widgets/loading_widget.dart';
import 'widgets/no_device_layout.dart';
import 'widgets/scrolling_list_view.dart';
import 'widgets/video_player.dart';

final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();

final Map<int, String> indexToLetter = <int, String>{
  0: "A",
  1: "B",
  2: "C",
  3: "D"
};

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Device device = ModalRoute.of(context)!.settings.arguments as Device;
    final ScreenshotController screenshotController = ScreenshotController();

    SocketService().logout.listen((event) async => Utils.logout());

    SocketService().command.listen((event) async {
      if (event[0] == 1) {
        Restart.restartApp();
      } else if (event[0] == 2) {
        final imageData = await screenshotController.capture();
        Utils.sendScreenshot(imageData, event[1]);
      } else if (event[0] == 3) {
        Utils.wipeData();
      } else if (event[0] == 5) {
        final dir = await getDownloadsDirectory();
        if (dir == null) {
          return;
        }
        Utils.downloadApk(getInstance(), Version.fromJson(event[1]));
      } else if (event[0] == 6) {
        final res = await Utils.runADBCommand(event[1]['command']);
        SocketService().emitCommandResult(event[1]['sessionId'],
            res ?? "Command executed with null response");
      }
    });

    return WillPopScope(
      onWillPop: () async {
        showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                  child: SingleChildScrollView(
                child: Column(children: [
                  const Text("Settings",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  // Bluetooth setting
                  ListTile(
                      title: const Text("Bluetooth"),
                      trailing: const Icon(Icons.bluetooth,
                          color: ColorManager.secondary),
                      onTap: () => showDialog(
                          context: context,
                          builder: (context) => Dialog(
                              backgroundColor: ColorManager.white,
                              child: Column(
                                children: [
                                  const Text("Connect to Bluetooth Device",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  const BluetoothConnectionPage(),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          side: const BorderSide(
                                              width: 1.0, color: Colors.black),
                                          backgroundColor: ColorManager.white,
                                          elevation: 0,
                                          fixedSize: Size(
                                              AppConstants.deviceWidth * 0.25,
                                              AppConstants.deviceHeight *
                                                  0.05)),
                                      onPressed: () async {
                                        // final bluetoothConnected;
                                        // if (bluetoothConnected && context.mounted) {
                                        //   Navigator.pop(context);
                                        // }
                                      },
                                      child: const Text(
                                        "Connect to Bluetooth Device",
                                        style: TextStyle(
                                            color: ColorManager.black),
                                      )),
                                ],
                              )))),
                  const Divider(),
                ]),
              ));
            });
        return false;
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider<NetworkCubit>(
            create: (BuildContext context) =>
                NetworkCubit(networkInfo: getInstance()),
          ),
          BlocProvider<WardsInfoBloc>(
            create: (BuildContext context) =>
                WardsInfoBloc(downloadVideo: getInstance()),
          ),
          BlocProvider<WardsPersonnelBloc>(
            create: (BuildContext context) => WardsPersonnelBloc(),
          ),
          BlocProvider<WardsNewsBloc>(
            create: (BuildContext context) => WardsNewsBloc(),
          ),
          BlocProvider<LayoutsCubit>(
            create: (BuildContext context) => LayoutsCubit(
              device: device,
              downloadVideo: getInstance(),
              fetchDeviceLayout: getInstance(),
              fetchCustomUser: getInstance(),
              fetchWardDetails: getInstance(),
              wardsInfoBloc: context.read<WardsInfoBloc>(),
              wardsPersonnelBloc: context.read<WardsPersonnelBloc>(),
              wardsNewsBloc: context.read<WardsNewsBloc>(),
            ),
          ),
          BlocProvider<InformationBloc>(
            create: (BuildContext context) =>
                InformationBloc(screenBrightness: getInstance())..init(),
          ),
          BlocProvider<stb.ScrollingTextBloc>(
            create: (BuildContext context) =>
                stb.ScrollingTextBloc(fetchScrollingTexts: getInstance())
                  ..init(),
          ),
          BlocProvider<TokenBloc>(
            create: (BuildContext context) => TokenBloc(device: device),
          ),
          BlocProvider<ContentsBloc>(
            create: (BuildContext context) => ContentsBloc(
                remoteDatasource: getInstance(),
                fetchContents: getInstance(),
                download: getInstance(),
                tokenBloc: context.read<TokenBloc>())
              ..init(),
          ),
          BlocProvider<FeedbackCubit>(
            create: (BuildContext context) => FeedbackCubit(
                fetchFeedbackQuestions: getInstance(),
                submitFeedbackAnswer: getInstance(),
                device: device)
              ..init(),
          ),
        ],
        child: Screenshot(
          controller: screenshotController,
          child: BlocBuilder<LayoutsCubit, LayoutsState>(
            buildWhen: (previous, current) {
              if (current is LayoutsLoaded) {
                return current.shouldRebuild;
              }
              return true;
            },
            builder: (context, state) {
              Utils.setDeviceDimentionsByOrientation(
                  context, state.forceOrientation);
              return RotatedBox(
                quarterTurns: Utils.getRotation(state.forceOrientation),
                child: CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.keyX): () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Are you sure?'),
                          content: const Text(
                              'Do you want to locally delete all contents?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.of(context).pop,
                                child: const Text('No')),
                            TextButton(
                                onPressed: () async {
                                  await Utils.deleteAllContents();
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text('Yes')),
                          ],
                        ),
                      ).then((value) {
                        if (value == true) {
                          SystemNavigator.pop();
                        }
                      });
                    }
                  },
                  child: Scaffold(
                    body: Builder(
                      builder: (context) {
                        // Rotation to change layout orientation
                        SocketService().command.listen((event) async {
                          if (event[0] == 4) {
                            HiveService().addOrientationToBox(event[1]);
                            final DeviceLayoutInfo? deviceLayout =
                                HiveService().getLayouts();
                            if (deviceLayout != null &&
                                deviceLayout.orientation == "portrait" &&
                                event[1] == "LEFT") {
                              context.read<LayoutsCubit>().changeOrientation(
                                  context, ForceOrientation.portraitLeft);
                            } else if (deviceLayout != null &&
                                deviceLayout.orientation == "portrait" &&
                                event[1] == "RIGHT") {
                              context.read<LayoutsCubit>().changeOrientation(
                                  context, ForceOrientation.portraitRight);
                            } else if (deviceLayout != null &&
                                deviceLayout.orientation == "landscape" &&
                                event[1] == "LEFT") {
                              context.read<LayoutsCubit>().changeOrientation(
                                  context, ForceOrientation.landscapeBottom);
                            } else if (deviceLayout != null &&
                                deviceLayout.orientation == "landscape" &&
                                event[1] == "RIGHT") {
                              context.read<LayoutsCubit>().changeOrientation(
                                  context, ForceOrientation.landscapeTop);
                            }
                          }
                        });

                        debugPrint("""
                                                Entire Layout Rebuilding
                                                _________________________
                                  """);
                        // Device Inactive State
                        if (state is LayoutsInactive) {
                          return DeviceInactive(state: state);
                        }
                        // Layouts Loading State
                        if (state is LayoutsLoading) {
                          return const LoadingWidget(
                              title: "Getting Layouts Ready");
                          // No Device Layout State
                        } else if (state is NoDeviceLayout) {
                          return NoDeviceLayoutWidget(state: state);
                        } else if (state is LayoutsLoaded) {
                          return CallbackShortcuts(
                              bindings: {
                                const SingleActivator(LogicalKeyboardKey.keyD):
                                    () {
                                  EasyLoading.showInfo(
                                      "nStored DateTime: ${HiveService().getStoredDateTime()}\nCurrent DateTime: ${DateTime.now()}\nAppConstant.now: ${AppConstants.now}\nAppConstant.ntpNow: ${AppConstants.ntpNow}",
                                      duration: const Duration(seconds: 30));
                                },
                                const SingleActivator(LogicalKeyboardKey.keyF):
                                    () async {
                                  final hasInternetFuture =
                                      Utils.checkConnection();
                                  final ssidFuture = WiFiForIoTPlugin.getSSID();
                                  final ipAddressFuture =
                                      WiFiForIoTPlugin.getIP();
                                  final isConnectedFuture =
                                      WiFiForIoTPlugin.isConnected();
                                  final ethernetIPFuture = Utils.runADBCommand(
                                      "ip -4 address show eth0 | sed -n -e 's/.*inet \\([0-9.]*\\).*/\\1/p'");

                                  final res = await Future.wait([
                                    hasInternetFuture,
                                    ssidFuture,
                                    ipAddressFuture,
                                    isConnectedFuture,
                                    ethernetIPFuture
                                  ]);

                                  EasyLoading.showInfo("""
                                  SSID: ${res[1]}
                                  IP Address: ${res[2]}
                                  Connected: ${res[3]} (does not necessarily mean internet working)
                                  Internet Connection: ${res[0]}
                                  Ethernet IP: ${res[4]}
                                  """, duration: const Duration(seconds: 30));
                                },
                                const SingleActivator(
                                    LogicalKeyboardKey.arrowUp): () {
                                  EasyLoading.dismiss();
                                },
                                const SingleActivator(LogicalKeyboardKey.keyY):
                                    () async {
                                  EasyLoading.showInfo(
                                      "All Downloading List\n${AppConstants.downloadingList}",
                                      duration: const Duration(seconds: 30));
                                },
                                const SingleActivator(LogicalKeyboardKey.keyT):
                                    () async {
                                  String version =
                                      await Utils.getCurrentVersion();
                                  final message =
                                      "Signage Plus\n${AppConstants.date} (v$version)";
                                  if (context.mounted) {
                                    EasyLoading.showInfo(message,
                                        duration: const Duration(seconds: 30));
                                  }
                                },
                                const SingleActivator(LogicalKeyboardKey.keyN):
                                    () {
                                  context
                                      .read<ContentsBloc>()
                                      .add(const ChangeContent());
                                },
                                const SingleActivator(LogicalKeyboardKey.keyR):
                                    () {
                                  Restart.restartApp();
                                },
                              },
                              child: Focus(
                                  autofocus: true,
                                  child: Stack(children: [
                                    Positioned(
                                      top: 20,
                                      right: 150,
                                      child: BlocConsumer<NetworkCubit,
                                          NetworkState>(
                                        listener:
                                            (context, networkState) async {
                                          if (networkState
                                              is NetworkDisconnected) {
                                            // if (state.type == AppConstants.layoutToken || state.type == AppConstants.layoutTokenButton) {
                                            //   context.read<TokenBloc>().disconnectToken();
                                            // }
                                          }
                                          if (networkState
                                              is NetworkConnected) {
                                            if (state.type ==
                                                    AppConstants.layoutToken ||
                                                state.type ==
                                                    AppConstants
                                                        .layoutTokenButton) {
                                              if (!context
                                                  .read<NetworkCubit>()
                                                  .firstLoad) {
                                                Restart.restartApp();
                                              }
                                              context
                                                  .read<NetworkCubit>()
                                                  .firstLoad = false;
                                              context
                                                  .read<TokenBloc>()
                                                  .loadToken(state.type);
                                            }
                                            // if internet restored
                                            final result = await getInstance<
                                                    c.CheckDeviceId>()
                                                .call(c.Params(
                                                    deviceId: AppConstants
                                                        .deviceId!));
                                            result.fold((l) {}, (r) async {
                                              if (!r) await Utils.logout();
                                            });

                                            // get latest ward details
                                            if (state.type ==
                                                AppConstants.layoutTypeWard) {
                                              final result = await getInstance<
                                                      w.FetchWardDetails>()
                                                  .call(const w.Params());
                                              result.fold(
                                                  (left) => debugPrint(
                                                      "ERROR : ${left.message}"),
                                                  (right) async => await context
                                                      .read<LayoutsCubit>()
                                                      .fetchWard());
                                            }
                                            // get custom user conditions
                                            if (state.type ==
                                                AppConstants.layoutTypeCustom) {
                                              final result = await getInstance<
                                                      FetchCondition>()
                                                  .call(Params(
                                                      deviceId: AppConstants
                                                          .deviceId!));
                                              result.fold(
                                                  (left) => null,
                                                  (right) => context
                                                      .read<LayoutsCubit>()
                                                      .updateConditions(right));
                                            }
                                            // sync play logs and retrieve device info
                                            LogService.syncLogsFromHive();
                                            SocketService().socket?.emit(
                                                "getDeviceInfo",
                                                AppConstants.deviceId);
                                          }
                                        },
                                        builder: (context, state) {
                                          if (state is NetworkUnknown) {
                                            return const Row(
                                              children: [
                                                Icon(Icons.warning,
                                                    color:
                                                        ColorManager.secondary),
                                                Text("Internet"),
                                              ],
                                            );
                                          }
                                          // if (state is NetworkDisconnected) {
                                          //   return const Row(children: [
                                          //     Icon(
                                          //       Icons.error,
                                          //       color: ColorManager.errorRed,
                                          //     ),
                                          //     Text("Internet")
                                          //   ]);
                                          // }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                    if (state.type ==
                                        AppConstants.layoutTypeCustom) ...[
                                      const SizedBox(width: 7.5),
                                      ScrollingListView(
                                        key: UniqueKey(),
                                        padding: state.padding,
                                        builder: buildLayoutInfo,
                                        layout: state.layouts,
                                        stopDuration: state.stopDuration,
                                      )
                                    ] else if (state.type ==
                                        AppConstants.layoutTypeWard) ...[
                                      Container(
                                          padding: state.padding,
                                          height: double.maxFinite,
                                          child: Column(
                                            children: [
                                              buildLayoutInfo(
                                                  context, state.layouts,
                                                  wardSettings:
                                                      state.wardSettings),
                                            ],
                                          )),
                                    ] else ...[
                                      Container(
                                          padding: state.padding,
                                          height: double.maxFinite,
                                          child: Column(
                                            children: [
                                              buildLayoutInfo(
                                                  context, state.layouts),
                                            ],
                                          )),
                                    ]
                                  ])));
                        } else if (state is LayoutsError) {
                          return Center(child: Text(state.message));
                        }
                        return const Center(child: Text("Unknown error"));
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildLayoutInfo(BuildContext context, DeviceLayout layoutInfo,
      {int? index, WardSettings? wardSettings}) {
    final dataType = layoutInfo.data?.dataType;

    if (layoutInfo.children == null || layoutInfo.children!.isEmpty) {
      switch (dataType) {
        case DataTypes.header:
          return HeaderWidget(layoutInfo: layoutInfo);
        case DataTypes.personnel:
          return PersonnelWidget(
              layoutInfo: layoutInfo, wardSettings: wardSettings);
        case DataTypes.ward:
          return WardsWidget(
              layoutInfo: layoutInfo, wardSettings: wardSettings);
        case DataTypes.news:
          return NewsWidget(layoutInfo: layoutInfo, wardSettings: wardSettings);
        case DataTypes.image:
          return ImageWidget(layoutInfo: layoutInfo, index: index!);
        case DataTypes.token:
          return TokenWidget(layoutInfo: layoutInfo);
        case DataTypes.quiz:
          return QuizWidget(
              layoutInfo: layoutInfo, formStateKey: _formStateKey);
        case DataTypes.tokenButton:
          return TokenButtonWidget(layoutInfo: layoutInfo);
        case DataTypes.text:
          return TextWidget(layoutInfo: layoutInfo, index: index!);
        case DataTypes.boolean:
          return BooleanWidget(layoutInfo: layoutInfo, index: index!);
        case DataTypes.weatherAndTime:
          return WeatherAndTimeWidget(layoutInfo: layoutInfo);
        case DataTypes.info:
          return InfoWidget(layoutInfo: layoutInfo);
        case DataTypes.scrollNews:
          return ScrollNewsWidget(layoutInfo: layoutInfo);
        case DataTypes.content:
          return BlocBuilder<FeedbackCubit, FeedbackState>(
            builder: (context, state) {
              return ContentWidget(
                  feedbackCubit: context.read<FeedbackCubit>(),
                  layoutInfo: layoutInfo,
                  getContentWidget: _getContentWidget,
                  showFrontSide: state is FeedbackLoaded
                      ? context.read<FeedbackCubit>().showFrontSide
                      : true);
            },
          );
        default:
          // return Expanded(flex: layoutInfo.flex ?? 1, child: const Placeholder());
          return const SizedBox.shrink();
      }
    }

    return Expanded(
      flex: layoutInfo.flex ?? 1,
      child: layoutInfo.type == "Row"
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: layoutInfo.children!
                  .map((child) => buildLayoutInfo(context, child,
                      index: index, wardSettings: wardSettings))
                  .toList(),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: layoutInfo.children!
                  .map((child) => buildLayoutInfo(context, child,
                      index: index, wardSettings: wardSettings))
                  .toList(),
            ),
    );
  }

  Widget _getContentWidget(BuildContext context, DeviceLayout layoutInfo,
      ContentsState state, bool showFrontSide) {
    if (state is LoadedContents) {
      // if (state.content.isFullscreenContent) {
      //   return SizedBox(
      //     height: AppConstants.deviceHeight - context.read<LayoutsCubit>().padding.vertical,
      //     width: AppConstants.deviceWidth - context.read<LayoutsCubit>().padding.horizontal,
      //     child: Stack(children: [
      //       Column(children: [buildContentLayout(context, state.content.layout)]),
      //       if (state.content.layout.overlay != null) ...[
      //         Positioned(
      //           top: AppConstants.deviceHeight * Utils.percentageToDouble(state.content.layout.overlay!.config.top),
      //           left: AppConstants.deviceWidth * Utils.percentageToDouble(state.content.layout.overlay!.config.left),
      //           child: CachedNetworkImage(
      //               imageUrl: state.content.layout.overlay!.url,
      //               fit: BoxFit.fill,
      //               height: AppConstants.deviceHeight * Utils.percentageToDouble(state.content.layout.overlay!.config.height),
      //               width: AppConstants.deviceWidth * Utils.percentageToDouble(state.content.layout.overlay!.config.width)),
      //         ),
      //       ],
      //     ]),
      //   );
      // }
      return Expanded(
        flex: layoutInfo.flex ?? 1,
        child:
            //  FlipFeedbackWidget(
            //   showFrontSide: showFrontSide,
            //   feedbackCubit: context.read<FeedbackCubit>(),
            //   child:
            Stack(children: [
          Column(
            children: [
              buildContentLayout(context, layoutInfo: state.content.layout)
            ],
          ),
          if (state.content.layout.overlay != null) ...[
            Positioned(
              top: AppConstants.deviceHeight *
                  Utils.percentageToDouble(
                      state.content.layout.overlay!.config.top),
              left: AppConstants.deviceWidth *
                  Utils.percentageToDouble(
                      state.content.layout.overlay!.config.left),
              child: CachedNetworkImage(
                  imageUrl: state.content.layout.overlay!.url,
                  fit: BoxFit.fill,
                  height: AppConstants.deviceHeight *
                      Utils.percentageToDouble(
                          state.content.layout.overlay!.config.height),
                  width: AppConstants.deviceWidth *
                      Utils.percentageToDouble(
                          state.content.layout.overlay!.config.width)),
            ),
          ],
        ]),
        // ),
      );
    } else if (state is EmptyContents) {
      return Expanded(
        flex: layoutInfo.flex ?? 1,
        // child:
        //  FlipFeedbackWidget(
        //   showFrontSide: showFrontSide,
        //   feedbackCubit: context.read<FeedbackCubit>(),
        child: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/images/no_content.svg",
                    fit: BoxFit.contain,
                    height: AppConstants.deviceHeight * 0.3),
                Divider(
                  height: 20,
                  thickness: 1,
                  endIndent: AppConstants.deviceWidth * 0.35,
                  indent: AppConstants.deviceWidth * 0.35,
                ),
                SizedBox(height: AppConstants.deviceHeight * 0.02),
                const Text(
                  "We are unable to find any content to display.\nPlease add content so, that we can display it in digital signage.\nThank you !",
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
        // ),
      );
    } else {
      return const LoadingWidget(title: "Getting Contents Ready");
    }
  }
}

class QuizPlayingWidget extends StatefulWidget {
  final QuizPlaying state;

  const QuizPlayingWidget({
    super.key,
    required this.state,
  });

  @override
  State<QuizPlayingWidget> createState() => _QuizPlayingWidgetState();
}

class _QuizPlayingWidgetState extends State<QuizPlayingWidget> {
  List<bool> isClicked = List.filled(10, false);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: context.read<QuizCubit>().pageController,
        itemCount: 10,
        itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    "Question ${index + 1}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppConstants.deviceHeight * 0.1),
                  Text(
                    widget.state.quiz[index].question,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppConstants.deviceHeight * 0.07),
                  GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 4,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, i) => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                backgroundColor: isClicked[index]
                                    ? widget.state.quiz[index].answers[i] ==
                                            widget
                                                .state.quiz[index].correctAnswer
                                        ? Colors.greenAccent
                                        : Colors.redAccent
                                    : ColorManager.primary,
                                elevation: 0,
                                fixedSize: Size(AppConstants.deviceWidth * 0.25,
                                    AppConstants.deviceHeight * 0.15)),
                            onPressed: () {
                              if (isClicked[index]) return;
                              setState(() {
                                isClicked[index] = true;
                              });
                              context.read<QuizCubit>().submitAnswer(
                                  widget.state.quiz[index],
                                  widget.state.quiz[index].answers[i]);
                              Timer(const Duration(seconds: 1), () {
                                if (index == 9) {
                                  setState(() {
                                    isClicked.fillRange(0, 10, false);
                                  });
                                }
                                context
                                    .read<QuizCubit>()
                                    .changeQuestion(context);
                              });
                            },
                            child: Text(
                                "${indexToLetter[i]}: ${widget.state.quiz[index].answers[i]}"),
                          ))
                ],
              ),
            ));
  }
}

Widget buildContentLayout(BuildContext context,
    {required ContentLayout layoutInfo, String? contentId}) {
  final dataType = layoutInfo.data?.fileType;
  final margin = layoutInfo.margin;

  if (dataType == null) {
    return Expanded(
      flex: layoutInfo.flex,
      child: layoutInfo.type == "Row"
          ? Row(
              children: layoutInfo.children!
                  .map((child) => buildContentLayout(context,
                      layoutInfo: child, contentId: contentId))
                  .toList(),
            )
          : Column(
              children: layoutInfo.children!
                  .map((child) => buildContentLayout(context,
                      layoutInfo: child, contentId: contentId))
                  .toList(),
            ),
    );
  } else {
    if (dataType == "video") {
      final UniqueKey uniqueKey = UniqueKey();
      context.read<ContentsBloc>().videoCompletion[uniqueKey.toString()] =
          false;
      return Expanded(
        flex: layoutInfo.flex,
        child: Padding(
          padding: EdgeInsets.only(
            left: margin!.contains('left')
                ? AppConstants.deviceWidth * 0.0025
                : 0,
            right: margin.contains('right')
                ? AppConstants.deviceWidth * 0.0025
                : 0,
            top: margin.contains('top') ? AppConstants.deviceWidth * 0.0025 : 0,
            bottom: margin.contains('bottom')
                ? AppConstants.deviceWidth * 0.0025
                : 0,
          ),
          child: VideoWidget(
            context.read<ContentsBloc>(),
            layoutInfo.data!.fileContent,
            volume: context.read<InformationBloc>().volume,
            key: uniqueKey,
          ),
        ),
      );
    }

    if (dataType == "image") {
      return Expanded(
        flex: layoutInfo.flex,
        child: Container(
          padding: EdgeInsets.only(
            left: margin!.contains('left')
                ? AppConstants.deviceWidth * 0.0025
                : 0,
            right: margin.contains('right')
                ? AppConstants.deviceWidth * 0.0025
                : 0,
            top: margin.contains('top') ? AppConstants.deviceWidth * 0.0025 : 0,
            bottom: margin.contains('bottom')
                ? AppConstants.deviceWidth * 0.0025
                : 0,
          ),
          height: double.maxFinite,
          width: AppConstants.deviceWidth,
          child: Image.file(
            File(
                "${HiveService.dir.path}/image/${layoutInfo.data!.fileContent.split("/").last}"),
            cacheHeight: 1080,
            cacheWidth: 1920,
            fit: BoxFit.fill,
          ),
        ),
      );
    }
    if (dataType == "url") {
      return Expanded(
        flex: layoutInfo.flex,
        child: LinkPreviewWidget(layoutInfo.data!.fileContent,
            isPortrait: context.read<LayoutsCubit>().isPortrait ?? false),
      );
    }
  }
  if (dataType == "text") {
    return Expanded(
      flex: layoutInfo.flex,
      child: AutoScrollHtmlWidget(
          html: layoutInfo.data!.fileContent,
          key: UniqueKey(),
          scrollSpeed: 10),
    );
  }
  return Expanded(
    flex: layoutInfo.flex,
    child: const Placeholder(),
  );
}
