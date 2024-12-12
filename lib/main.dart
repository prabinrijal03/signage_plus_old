import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
// import 'package:bluetooth_print/bluetooth_print.dart';
// import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_usb_printer/flutter_usb_printer.dart';
import 'package:path_provider/path_provider.dart';
import 'data/usecases/fetch_contents.dart';
import 'data/usecases/set_version.dart' as s;
import 'services/utils.dart';

import 'core/dependency_injection.dart';
import 'data/model/version.dart';
import 'presentation/homescreen/home_screen.dart';
import 'presentation/login/login_page.dart';
import 'presentation/splashscreen/splashscreen.dart';
import 'resources/constants.dart';
import 'services/hive_services.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // AppConstants.isRooted = await Utils.isDeviceRooted();
  AppConstants.isRooted = false;
  tz.initializeTimeZones();
  // Initialize Hive Services
  await HiveService.init();
  DependencyInjection.initAppModule();

  Utils.runADBCommand("whoami");
  // Utils.makeDefaultLauncher();

  try {
    Utils.installUpdater();
    if (AppConstants.isRooted ?? false) {
      final downloadDir = await getDownloadsDirectory();
      if (downloadDir != null) {
        final File file = File("${downloadDir.path}/apk/update_info.txt");
        if (file.existsSync()) {
          final String content = await file.readAsString();
          final UpdateInfo updateInfo =
              UpdateInfo.fromJson(jsonDecode(content));
          final String? deviceId = HiveService().getDeviceId();
          List<Future> futures = [];

          if (updateInfo.updated != null &&
              updateInfo.id != null &&
              deviceId != null) {
            if (updateInfo.updated!) {
              HiveService().addCurrentVersionIdToBox(updateInfo.id!);
              futures.add(getInstance<s.SetVersion>().call(
                  s.Params(deviceId: deviceId, versionId: updateInfo.id!)));
            }
            /* 
            Sending Version Update Acknowledge to the server with existing sendContentRemarks API
            Content ID is "version" in the backend database 
            */
            futures.add(getInstance<FetchContents>().sendContentRemarks(
                RemarkParams(
                    "version",
                    deviceId,
                    updateInfo.versionName!,
                    HiveService().getStoredDateTime()?.toIso8601String() ??
                        DateTime.now().toIso8601String(),
                    updateInfo.remark!)));
          }

          await Future.wait(futures);
          file.delete();
        }
      }
    }
  } catch (_) {}

  // final res = await FlutterUsbPrinter.getUSBDeviceList();
  // if (res.isNotEmpty) {
  //   for (int i = 0; i < res.length; i++) {
  //     print("RESSS ::: ${res[i]}");
  //     final vendorId = res[i]['vendorId'] as String;
  //     final productId = res[i]['productId'] as String;
  //     final name = res[i]['productName'] as String;
  //     if (!(name.toLowerCase().contains("printer"))) continue;
  //     try {
  //       FlutterUsbPrinter().connect(int.parse(vendorId), int.parse(productId));
  //     } catch (e) {
  //       continue;
  //     }
  //   }
  //   while ((await Utils.runADBCommand("dumpsys activity recents | grep 'Recent #0' | cut -d= -f2 | sed 's| .*||' | cut -d '/' -f1")) ==
  //       "[com.android.systemui]") {
  //     await Utils.runADBCommand("input tap 901.5 455.5");
  //   }
  // }

  BluetoothThermalPrinter.connect("66:22:6A:04:50:03");

  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    AppConstants.setDeviceDimension(
        MediaQuery.of(context).size.height, MediaQuery.of(context).size.width);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.home): () {
          AppSettings.openAppSettings(
              type: AppSettingsType.wifi, asAnotherTask: true);
        },
        const SingleActivator(LogicalKeyboardKey.delete): () {
          AppSettings.openAppSettings(
              type: AppSettingsType.date, asAnotherTask: true);
        },
        const SingleActivator(LogicalKeyboardKey.end): () {
          AppSettings.openAppSettings(
              type: AppSettingsType.developer, asAnotherTask: true);
        },
        const SingleActivator(LogicalKeyboardKey.insert): () {
          AppSettings.openAppSettings(
              type: AppSettingsType.device, asAnotherTask: true);
        },
      },
      child: MaterialApp(
        builder: EasyLoading.init(),
        title: 'SlashPlus',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: false, fontFamily: 'Poppins'),
        initialRoute: "/",
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginPage(),
          "/homescreen": (context) => const HomeScreen(),
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
