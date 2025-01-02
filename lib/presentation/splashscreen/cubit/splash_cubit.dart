import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:slashplus/data/datasource/remote_datasource.dart';
import '../../../core/dependency_injection.dart';
import '../../../data/usecases/check_device_id.dart';

import '../../../services/hive_services.dart';
import '../../../services/socket_services.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final HiveService hiveService;
  SplashCubit({required this.hiveService}) : super(SplashLoading());

  Future<void> init(BuildContext context) async {
    await [
      Permission.manageExternalStorage,
      Permission.storage,
      Permission.requestInstallPackages
    ].request();

    // Get device id from hive
    String? deviceId = hiveService.getDeviceId();
    if (deviceId != null) {
      final result =
          await getInstance<CheckDeviceId>().call(Params(deviceId: deviceId));
      result.fold((l) {
        debugPrint(l.message);
      }, (r) {
        if (!r) Navigator.pushReplacementNamed(context, '/login');
      });
      try {
        RemoteDatasource remoteDataSource = getInstance();
        bool isForcePlayEnabled =
            await remoteDataSource.forcePLayEnabled(deviceId);
        if (isForcePlayEnabled) {
          print("Force play is enabled");
          hiveService.savedForcePlayStatus(isForcePlayEnabled);
        } else {
          print("Force play is not enabled");
        }
      } catch (e) {
        print("Error occurred while checking force play: $e");
      }
    }

    // Delay 2 seconds and navigate to login screen if device id is null
    // else navigate to home screen
    await Future.delayed(const Duration(seconds: 1), () {
      if (deviceId == null) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // Initialize socket service
        SocketService().initSocket(deviceId);
        Navigator.pushReplacementNamed(context, '/homescreen',
            arguments: hiveService.getDeviceFromBox());
      }
    });
  }
}
