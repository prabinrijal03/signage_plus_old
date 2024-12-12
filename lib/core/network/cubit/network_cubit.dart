import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../resources/constants.dart';
import '../../../services/hive_services.dart';
import '../../../services/utils.dart';
import '../internet_checker.dart';

part 'network_state.dart';

class NetworkCubit extends Cubit<NetworkState> {
  final NetworkInfo networkInfo;
  NetworkCubit({required this.networkInfo}) : super(NetworkUnknown()) {
    init();
  }
  DateTime? lastUpdatedAt;
  bool firstLoad = true;

  Future<void> init() async {
    networkInfo.networkStatus.listen((event) {
      event == InternetStatus.connected
          ? emit(NetworkConnected())
          : emit(NetworkDisconnected());
    });

    dateTimeStream.listen((event) async {
      if (state is NetworkConnected) {
        HiveService().addDateTimeToBox(AppConstants.ntpNow);
        if (lastUpdatedAt != null &&
            lastUpdatedAt!
                .isAfter(DateTime.now().subtract(const Duration(hours: 1)))) {
          HiveService().incrementStoredDateTime();
          return;
        }

        try {
          lastUpdatedAt = DateTime.now();
          if (AppConstants.useServerDateTime) {
            AppConstants.ntpNow =
                await Utils.getTimeFromServer() ?? DateTime.now();
          } else {
            AppConstants.ntpNow = await Utils.getTimeFromNTP();
          }
        } catch (_) {
          AppConstants.ntpNow = DateTime.now();
        }
      } else {
        HiveService().incrementStoredDateTime();
      }
    });

    await networkInfo.isConnected
        ? emit(NetworkConnected())
        : emit(NetworkDisconnected());
  }

  final Stream<DateTime> dateTimeStream =
      Stream.periodic(const Duration(seconds: 1), (i) => AppConstants.ntpNow)
          .asBroadcastStream();
}
