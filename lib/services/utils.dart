import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_usb_printer/flutter_usb_printer.dart';
import 'package:ntp/ntp.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restart_app/restart_app.dart';
// import 'package:slashplus/core/extensions.dart';
import 'package:slashplus/data/usecases/get_server_datetime.dart';
import 'package:video_compress/video_compress.dart';
import '../data/model/scroll_text.dart';
import '../data/model/contents.dart';
import '../data/model/version.dart';
import '../data/usecases/set_version.dart' as s;
import '../resources/color_manager.dart';
import '../core/dependency_injection.dart';
import '../data/usecases/fetch_contents.dart';
import '../presentation/homescreen/cubit/layouts/layouts_cubit.dart';
import 'socket_services.dart';
import 'package:uuid/uuid.dart';

import '../data/usecases/download_video.dart' as d;
import '../resources/constants.dart';
import 'hive_services.dart';
import 'package:timezone/timezone.dart';

class Utils {
  // static String getBaseUrl() {
  //   final hiveBaseUrl = HiveService().getBaseUrl();
  //   if (hiveBaseUrl != null) return hiveBaseUrl;

  //   final file = File('/storage/emulated/0/config.json');
  //   if (file.existsSync()) {
  //     final config = jsonDecode(file.readAsStringSync());
  //     return config['baseUrl'];
  //   }

  //   return UrlConstants.baseUrl;
  // }

  // static String getVersionUrl() {
  //   final hiveBaseUrl = HiveService().getBaseUrl();
  //   if (hiveBaseUrl != null) return hiveBaseUrl + UrlConstants.version;

  //   final file = File('/storage/emulated/0/config.json');
  //   if (file.existsSync()) {
  //     final config = jsonDecode(file.readAsStringSync());
  //     return config['baseUrl'] + UrlConstants.version;
  //   }

  //   return UrlConstants.baseUrl + UrlConstants.version;
  // }

  // static void setBaseUrl(String baseUrl) {
  //   final file = File('/storage/emulated/0/config.json');
  //   if (!file.existsSync()) file.createSync();
  //   file.writeAsStringSync('{"baseUrl": "$baseUrl"}');

  //   HiveService().addBaseUrlToBox(baseUrl);
  // }
  static const platform = MethodChannel('native_channel');

  static Future<bool> checkConnection() {
    return Dio()
        .head(UrlConstants.baseUrl)
        .timeout(const Duration(seconds: 10))
        .then((value) => true)
        .catchError((onError) => false);
  }

  static Future<String> getCurrentVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.version;
    return appVersion;
  }

  static Future<String?> runADBCommand(String command) async {
    if (!(AppConstants.isRooted ?? false)) return '[Device is not rooted.]';

    final res =
        await platform.invokeMethod('runAdbCommand', {'command': command});
    debugPrint("RESULT OF su 0 '$command' : $res");
    return res;
  }

  static Future<void> makeDefaultLauncher() async {
    final result = await Utils.runADBCommand(
        "cmd shortcut get-default-launcher | grep 'Launcher' | cut -d'{' -f2 | cut -d'}' -f1 | cut -d'/' -f1");
    final defaultLauncher =
        result.toString().substring(1, result.toString().length - 1);
    debugPrint("DEFAULT LAUNCHER: $defaultLauncher");

    if (defaultLauncher != 'com.slashplus.signageplus') {
      debugPrint(await Utils.runADBCommand(
          "cmd package set-home-activity com.slashplus.signageplus/com.slashplus.signageplus.MainActivity"));
      if (defaultLauncher != 'com.android.tv.settings') {
        debugPrint(
            await Utils.runADBCommand("pm disable --user 0 $defaultLauncher"));
      }
    }
  }

  static Future<void> launchApp(String packageName) async {
    debugPrint(await Utils.runADBCommand(
        "monkey -p $packageName -c android.intent.category.LAUNCHER 1"));
  }

  static int getRotation(ForceOrientation orientation) {
    switch (orientation) {
      case ForceOrientation.landscapeTop:
        return 2;
      case ForceOrientation.portraitRight:
        return 1;
      case ForceOrientation.portraitLeft:
        return 3;
      default:
        return 0;
    }
  }

  static Future<bool> isDeviceRooted() async {
    final res = await platform.invokeMethod('checkRoot');
    debugPrint("isRooted? : $res");
    return res;
  }

  static Future<bool> installApk(String filePath) async {
    final res =
        await platform.invokeMethod('installApk', {'filePath': filePath});
    debugPrint("Apk Installed? : $res");
    return res;
  }

  static void installUpdater() async {
    final bool isRooted = AppConstants.isRooted ?? false;

    if (isRooted) {
      final apk = await Utils.copyAssetToFile("assets/signage_updater.apk");
      if (apk != null) {
        await runADBCommand('pm install -r ${apk.path}');
      }
    }
  }

  static double percentageToDouble(String percentage) {
    return double.parse(percentage.replaceAll('%', '')) / 100;
  }

  static void setDeviceDimentionsByOrientation(
      BuildContext context, ForceOrientation orientation) {
    AppConstants.forceOrientation = orientation;

    if (orientation == ForceOrientation.landscapeTop ||
        orientation == ForceOrientation.landscapeBottom) {
      AppConstants.deviceWidth = MediaQuery.of(context).size.width;
      AppConstants.deviceHeight = MediaQuery.of(context).size.height;
    } else {
      AppConstants.deviceWidth = MediaQuery.of(context).size.height;
      AppConstants.deviceHeight = MediaQuery.of(context).size.width;
    }
  }

  static Future<File?> copyAssetToFile(String assetPath) async {
    try {
      // Get the temporary directory of the app
      final Directory tempDir = await getTemporaryDirectory();

      if (File('${tempDir.path}/updater.apk').existsSync()) {
        return File('${tempDir.path}/updater.apk');
      }

      // Create a temporary file with a unique name
      final File tempFile = File('${tempDir.path}/updater.apk');

      // Load the asset
      final ByteData assetData = await rootBundle.load(assetPath);

      // Write the asset data to the temporary file
      await tempFile.writeAsBytes(assetData.buffer.asUint8List());

      return tempFile;
    } catch (e) {
      // Handle any errors that may occur while copying the asset to a file.
      debugPrint('Error copying asset to file: $e');
      return null;
    }
  }

  static Future<void> downloadContents(
      d.Donwload download, FetchContents fetchContents) async {
    final result = await fetchContents.fetchUrls(const Params());
    final remoteContents = result.fold((left) => null, (right) => right);

    if (remoteContents == null) return;

    // Get application directory
    final dir = HiveService.dir;

    final imageDownloads = remoteContents.imageLinks.map((c) async {
      final filename = c.url.split('/').last;

      if (File("${dir.path}/image/$filename").existsSync()) return;
      print("Downloading $filename and storing in ${dir.path}/image/$filename");
      final result = await download(
          d.Params(url: c.url, path: '${dir.path}/image/$filename'));
      await result.fold((l) {
        debugPrint("ERRRRORRRR ::: ${l.message}");
      }, (r) async {
        // Send Image Download Acknowledge to Server
        await fetchContents.sendContentRemarks(RemarkParams(
            c.id,
            AppConstants.deviceId!,
            c.url,
            HiveService().getStoredDateTime()?.toIso8601String() ??
                DateTime.now().toIso8601String(),
            RemarkConstants.firstDownload));
        debugPrint(
            'Downloaded $filename stored in ${dir.path}/image/$filename');
      });
    });

    final videoDownloads = remoteContents.videoLinks.map((c) async {
      final filename = c.url.split('/').last;

      if (File("${dir.path}/video/$filename").existsSync()) return;
      final result = await download(
          d.Params(url: c.url, path: '${dir.path}/video/$filename'));
      await result.fold((l) {
        debugPrint(l.message);
      }, (r) async {
        final videoFilePath = "${dir.path}/video/$filename";

        final thumbnail = await VideoCompress.getByteThumbnail(videoFilePath,
            quality: 100, position: 10);

        // Save the image bytes to a file
        final imageFile = File("${dir.path}/video/$filename.png");
        await imageFile.writeAsBytes(thumbnail?.toList() ?? []);

        // Send Video Download Acknowledge to Server
        await fetchContents.sendContentRemarks(RemarkParams(
            c.id,
            AppConstants.deviceId!,
            c.url,
            HiveService().getStoredDateTime()?.toIso8601String() ??
                DateTime.now().toIso8601String(),
            RemarkConstants.firstDownload));
        debugPrint(
            'Downloaded $filename stored in ${dir.path}/video/$filename');
      });
    });

    await Future.wait([...imageDownloads, ...videoDownloads]);
  }

  static Future<void> downloadWardContents(d.Donwload download,
      List<String> imageUrls, List<String> videoUrls) async {
    // Get application directory
    final dir = HiveService.dir;

    final imageDownloads = imageUrls.map((c) async {
      final filename = c.split('/').last;

      if (File("${dir.path}/image/$filename").existsSync()) return;
      final result = await download
          .call(d.Params(url: c, path: '${dir.path}/image/$filename'));
      await result.fold((l) {
        debugPrint(l.message);
      }, (r) async {
        debugPrint(
            'Downloaded $filename stored in ${dir.path}/image/$filename');
      });
    });

    final videoDownloads = videoUrls.map((c) async {
      final filename = c.split('/').last;

      if (File("${dir.path}/video/$filename").existsSync()) return;
      final result = await download
          .call(d.Params(url: c, path: '${dir.path}/video/$filename'));
      await result.fold((l) {
        debugPrint(l.message);
      }, (r) async {
        final videoFilePath = "${dir.path}/video/$filename";

        final thumbnail = await VideoCompress.getByteThumbnail(videoFilePath,
            quality: 100, position: 10);

        // Save the image bytes to a file
        final imageFile = File("${dir.path}/video/$filename.png");
        await imageFile.writeAsBytes(thumbnail?.toList() ?? []);

        debugPrint(
            'Downloaded $filename stored in ${dir.path}/video/$filename');
      });
    });

    await Future.wait([...imageDownloads, ...videoDownloads]);
  }

  static void downloadApk(d.Donwload download, Version versionData) async {
    // Get Downloads directory
    final dir = await getDownloadsDirectory();

    if (dir == null) {
      debugPrint('Could not get downloads directory');
      return;
    }

    const filename = "egangis.apk";

    if (File("${dir.path}/apk/$filename").existsSync()) {
      File("${dir.path}/apk/$filename").deleteSync();
    }
    final result = await download.call(d.Params(
        url: versionData.versionUrl, path: '${dir.path}/apk/$filename'));
    await result.fold((l) {
      debugPrint(l.message);
    }, (r) async {
      try {
        File file = File("${dir.path}/apk/update_info.txt");
        await file.writeAsString(jsonEncode(versionData.toJson()));

        debugPrint(
            'Downloaded $filename stored in ${dir.path}/apk/$filename with version info in ${dir.path}/apk/update_info.txt');

        if (AppConstants.isRooted ?? false) {
          await Utils.launchApp('com.slashplus.signage_updater');
          exit(0);
        } else {
          throw Exception("Device is not rooted");
        }
      } catch (e) {
        await installApk("${dir.path}/apk/$filename");

        HiveService().addCurrentVersionIdToBox(versionData.id);
        await Future.wait([
          getInstance<s.SetVersion>().call(s.Params(
              deviceId: HiveService().getDeviceId() ?? '',
              versionId: versionData.id)),
          // Content ID is "version" in the backend database
          getInstance<FetchContents>().sendContentRemarks(RemarkParams(
              "version",
              HiveService().getDeviceId() ?? '',
              versionData.versionName,
              HiveService().getStoredDateTime()?.toIso8601String() ??
                  DateTime.now().toIso8601String(),
              "App Updated to ${versionData.versionName} successfully"))
        ]);
      }
    });
  }

  static TimeOfDay parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final adjustedHour = hour < 0 || hour > 23 ? hour % 24 : hour;

    return TimeOfDay(hour: adjustedHour, minute: minute);
  }

  static String convertToNepaliNumbers(num number) {
    final englishNumbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    final nepaliNumbers = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];

    final result = StringBuffer();
    final numberStr = number.toString();

    for (int i = 0; i < numberStr.length; i++) {
      final digit = numberStr[i];

      if (digit == '.') {
        result.write('.'); // Preserve the decimal point
      } else {
        final digitIndex = englishNumbers.indexOf(digit);
        if (digitIndex != -1) {
          result.write(nepaliNumbers[digitIndex]);
        } else {
          result.write(digit);
        }
      }
    }

    return result.toString();
  }

  static Image getFlagFromCurrencyCode(String currencyCode, {int flex = 1}) {
    return Image.asset('assets/currency/${currencyCode.toLowerCase()}.png',
        width: flex * 50, height: flex * 50);
  }

  static String generateLogId(
      String deviceId, String contentId, String playTime) {
    Random random = Random();
    return const Uuid().v5("00000000-0000-0000-0000-000000000000",
        "$deviceId$contentId$playTime${random.nextInt(1000)}");
  }

  static Future<void> sendScreenshot(
      Uint8List? screenshotData, String token) async {
    if (screenshotData == null) return;
    String base64Image = base64Encode(screenshotData);

    // Send Screenshot to Server
    final result = await getInstance<FetchContents>()
        .sendScreenshot(ScreenshotParam(base64Image));
    result.fold((l) {
      SocketService().sendScreenshot(false, l.message, token);
      debugPrint("Screenshot failed to send. Error : ${l.message}");
    }, (r) {
      SocketService().sendScreenshot(true, r, token);
      debugPrint("Screenshot sent to server");
    });
  }

  static void restartApp() {
    Restart.restartApp();
  }

  static Future<bool> deleteAllContents() async {
    final dir = HiveService.dir;

    if (Directory("${dir.path}/video").existsSync()) {
      Directory("${dir.path}/video").deleteSync(recursive: true);
    }
    if (Directory("${dir.path}/image").existsSync()) {
      Directory("${dir.path}/image").deleteSync(recursive: true);
    }
    await Future.wait([
      HiveService.contentsBox.clear(),
      HiveService.wardContentBox.clear(),
      HiveService.scrollingTextsBox.clear(),
    ]);
    return true;
  }

  static Future<void> wipeData() async {
    await HiveService.clear();
    restartApp();
  }

  static Future<void> logout() async {
    HiveService().removeDeviceFromBox();
    await Future.wait(
      [
        HiveService.clear(),
        if (Directory("${HiveService.dir.path}/video").existsSync())
          Directory("${HiveService.dir.path}/video").delete(recursive: true),
        if (Directory("${HiveService.dir.path}/image").existsSync())
          Directory("${HiveService.dir.path}/image").delete(recursive: true),
      ],
    );

    wipeData();
  }

  // static Future<void> printToken(BuildContext context, String title, String counterType, String tokenNumber) async {
  //   Map<String, dynamic> config = {};

  //   List<LineText> list = [];

  //   list.add(LineText(
  //       type: LineText.TYPE_TEXT, content: '**********************************************', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
  //   list.add(
  //       LineText(type: LineText.TYPE_TEXT, content: '\n', weight: 2, fontZoom: 2, align: LineText.ALIGN_CENTER, x: 0, relativeX: 0, linefeed: 0));
  //   list.add(LineText(type: LineText.TYPE_TEXT, content: title, weight: 1, align: LineText.ALIGN_CENTER, fontZoom: 2, linefeed: 1));
  //   list.add(LineText(linefeed: 1));
  //   list.add(
  //       LineText(type: LineText.TYPE_TEXT, content: '\n', weight: 2, fontZoom: 2, align: LineText.ALIGN_CENTER, x: 0, relativeX: 0, linefeed: 0));
  //   list.add(LineText(type: LineText.TYPE_TEXT, content: counterType, weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
  //   list.add(LineText(type: LineText.TYPE_TEXT, content: 'Token Number\n', weight: 1, align: LineText.ALIGN_CENTER, x: 0, relativeX: 0, linefeed: 0));
  //   list.add(LineText(
  //       type: LineText.TYPE_TEXT, content: '$tokenNumber\n', weight: 2, fontZoom: 2, align: LineText.ALIGN_CENTER, x: 0, relativeX: 0, linefeed: 0));
  //   list.add(
  //       LineText(type: LineText.TYPE_TEXT, content: '\n', weight: 2, fontZoom: 2, align: LineText.ALIGN_CENTER, x: 0, relativeX: 0, linefeed: 0));
  //   list.add(LineText(
  //       type: LineText.TYPE_TEXT, content: '**********************************************', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
  //   list.add(LineText(linefeed: 1));
  //   try {
  //     BluetoothPrint.instance.printReceipt(config, list);
  //   } catch (e) {
  //     showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //               title: const Text('Error'),
  //               content: Text(e.toString()),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () => Navigator.pop(context),
  //                   child: const Text('OK'),
  //                 )
  //               ],
  //             ));
  //     debugPrint(e.toString());
  //   }
  // }

  static Future<bool> printFeedbackTicket(
      String ticketNumber, String deviceName) async {
    try {
      List<int> bytes = await getFeedbackTicket(ticketNumber, deviceName);
      final writeBytes = Uint8List.fromList(bytes);
      await platform.invokeMethod('write', {'byteArray': writeBytes});
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<int>> getFeedbackTicket(
      String ticketNumber, String deviceName) async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    bytes += generator.text("Nabil Bank Limited",
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    bytes += generator.text(deviceName,
        styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    bytes += generator.text("Feedback Ticket",
        styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2));
    bytes += generator.text("Reference Number",
        styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1));
    bytes += generator.text(ticketNumber,
        styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
            bold: true),
        linesAfter: 1);

    bytes += generator.text('Thank you!',
        styles: const PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.text(AppConstants.now.toLocal().toString(),
        styles: const PosStyles(align: PosAlign.center));

    bytes += generator.text('Hope you have a great day ahead!',
        styles: const PosStyles(align: PosAlign.center, bold: false));
    bytes += generator.cut();
    return bytes;
  }

  // static Future<bool> printFeedbackToken(String tokenNumber) async {
  //   Map<String, dynamic> config = {};

  //   List<LineText> list = [];

  //   list.add(LineText(
  //       type: LineText.TYPE_TEXT, content: '**********************************************', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
  //   list.add(
  //       LineText(type: LineText.TYPE_TEXT, content: '\n', weight: 2, fontZoom: 2, align: LineText.ALIGN_CENTER, x: 0, relativeX: 0, linefeed: 0));
  //   list.add(LineText(
  //       type: LineText.TYPE_TEXT, content: 'Thank you for your feedback!', weight: 1, align: LineText.ALIGN_CENTER, fontZoom: 2, linefeed: 1));
  //   list.add(LineText(linefeed: 1));

  //   list.add(
  //       LineText(type: LineText.TYPE_TEXT, content: 'Ticket Number\n', weight: 1, align: LineText.ALIGN_CENTER, x: 0, relativeX: 0, linefeed: 0));
  //   list.add(LineText(
  //       type: LineText.TYPE_TEXT, content: '$tokenNumber\n', weight: 2, fontZoom: 2, align: LineText.ALIGN_CENTER, x: 0, relativeX: 0, linefeed: 0));
  //   list.add(
  //       LineText(type: LineText.TYPE_TEXT, content: '\n', weight: 2, fontZoom: 2, align: LineText.ALIGN_CENTER, x: 0, relativeX: 0, linefeed: 0));
  //   list.add(LineText(
  //       type: LineText.TYPE_TEXT, content: '**********************************************', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
  //   list.add(LineText(linefeed: 1));
  //   try {
  //     await BluetoothPrint.instance.printReceipt(config, list);
  //     return true;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // static Future<void> printCongratulations(BuildContext context, String name, int score) async {
  //   if (context.read<TokenBloc>().isTokenPrinting) {
  //     Utils.showErrSnackbar(context, "Printing in progress. Please wait...");
  //     return;
  //   }

  //   Map<String, dynamic> config = {};

  //   List<LineText> list = [];

  //   list.add(LineText(
  //       type: LineText.TYPE_TEXT, content: '**********************************************', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
  //   list.add(
  //       LineText(type: LineText.TYPE_TEXT, content: "Congratulations $name.", weight: 1, align: LineText.ALIGN_CENTER, fontZoom: 2, linefeed: 1));
  //   list.add(LineText(linefeed: 1));

  //   list.add(LineText(type: LineText.TYPE_TEXT, content: "You scored:", weight: 2, align: LineText.ALIGN_CENTER, linefeed: 1));

  //   list.add(LineText(type: LineText.TYPE_TEXT, content: '$score', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));

  //   list.add(LineText(
  //       type: LineText.TYPE_TEXT, content: 'Thank you for visiting our Signage Plus stall.', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));

  //   list.add(LineText(
  //       type: LineText.TYPE_TEXT,
  //       content: 'Please scan the QR code below for more information.',
  //       weight: 1,
  //       align: LineText.ALIGN_CENTER,
  //       linefeed: 1));
  //   ByteData data = await rootBundle.load("assets/images/qr.png");
  //   List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  //   String base64Image = base64Encode(imageBytes);
  //   list.add(LineText(type: LineText.TYPE_IMAGE, content: base64Image, align: LineText.ALIGN_CENTER, linefeed: 1, x: 100, height: 500, width: 500));

  //   list.add(
  //       LineText(type: LineText.TYPE_TEXT, content: 'Or contact us at the number below.\n', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 2));
  //   list.add(LineText(type: LineText.TYPE_TEXT, content: 'Phone Number: 9802325546', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
  //   list.add(LineText(
  //       type: LineText.TYPE_TEXT, content: '**********************************************', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
  //   list.add(LineText(linefeed: 1));
  //   try {
  //     BluetoothPrint.instance.printReceipt(config, list);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  // static Future<List<int>> getTokenTicket(String counterType, String tokenNumber, String deviceName) async {
  //   List<int> bytes = [];
  //   CapabilityProfile profile = await CapabilityProfile.load();
  //   final generator = Generator(PaperSize.mm80, profile);

  //   bytes += generator.text("Nabil Bank Limited",
  //       styles: const PosStyles(
  //         align: PosAlign.center,
  //         height: PosTextSize.size2,
  //         width: PosTextSize.size2,
  //       ));

  //   bytes += generator.text(deviceName, styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
  //   bytes += generator.text(counterType, styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size2, width: PosTextSize.size2));
  //   bytes += generator.text("Token Number", styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size1, width: PosTextSize.size1));
  //   bytes += generator.text(tokenNumber,
  //       styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size4, width: PosTextSize.size4, bold: true), linesAfter: 1);

  //   bytes += generator.text('Thank you!', styles: const PosStyles(align: PosAlign.center, bold: true));

  //   bytes += generator.text(AppConstants.now.toLocal().toString(), styles: const PosStyles(align: PosAlign.center));

  //   bytes += generator.text('Hope you have a great day ahead!', styles: const PosStyles(align: PosAlign.center, bold: false), linesAfter: 2);

  //   bytes += generator.cut();
  //   return bytes;
  // }

  static Future<List<int>> getTokenTicket(String deviceName, String tokenNumber,
      String slotTime, bool onTime) async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    bytes += generator.text(deviceName,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));
    bytes += generator.text("Token Number",
        styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1));
    bytes += generator.text(tokenNumber,
        styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
            bold: true),
        linesAfter: 2);

    bytes += generator.text(
        'Time Slot: ${DateTime.parse(slotTime).toLocal().toString()}',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1);

    if (!onTime) {
      bytes += generator.text('Off time penalty',
          styles: const PosStyles(align: PosAlign.center, bold: true));
    }

    bytes += generator.text('Thank you!',
        styles: const PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.text(AppConstants.now.toLocal().toString(),
        styles: const PosStyles(align: PosAlign.center));

    bytes += generator.text('Hope you have a great day ahead!',
        styles: const PosStyles(align: PosAlign.center, bold: false),
        linesAfter: 2);

    bytes += generator.cut();
    return bytes;
  }

  static Future<bool> printTokenTicket(String deviceName, String tokenNumber,
      String slotTime, bool onTime) async {
    try {
      List<int> bytes =
          await getTokenTicket(deviceName, tokenNumber, slotTime, onTime);
      final writeBytes = Uint8List.fromList(bytes);
      // final res = await platform.invokeMethod<int>('write', {'byteArray': writeBytes});
      // final res = await FlutterUsbPrinter().write(writeBytes);
      final res = await BluetoothThermalPrinter.writeBytes(writeBytes.toList());
      // return (res ?? 0) > 0;
      return res == "true";
    } catch (e) {
      print('errorororororor:::: $e');
      return false;
    }
  }

  static List<int> splitIntegerWithPlaceValues(int number) {
    if (number < 10) {
      return [number];
    } else if (number >= 10 && number <= 20) {
      return [number];
    } else if (number < 100) {
      int tensDigit = number ~/ 10;
      int onesDigit = number % 10;
      return [tensDigit * 10, onesDigit];
    } else if (number >= 110 && number <= 120) {
      return [100, number - 100];
    } else {
      int hundredsDigit = number ~/ 100;
      int remaining = number % 100;

      final result = [
        hundredsDigit,
        100,
        ...splitIntegerWithPlaceValues(remaining)
      ];
      result.removeWhere((element) => element == 0);
      if (result.length > 1 && result[0] == 1) {
        result.removeAt(0);
      }
      return result;
    }
  }

  static Future<DateTime> getTimeFromNTP() async {
    try {
      // Fetch the current time from an NTP server
      DateTime currentTime =
          await NTP.now(lookUpAddress: UrlConstants.timeServerUrl);

      // Create a time zone for Kathmandu (UTC+5:45)
      final kathmanduTimeZone = getLocation('Asia/Kathmandu');
      final kathmanduTime = TZDateTime.from(currentTime, kathmanduTimeZone);

      return kathmanduTime;
    } catch (e) {
      debugPrint('Error fetching time: $e');
      return DateTime.now();
    }
  }

  static Future<DateTime?> getTimeFromServer() async {
    try {
      final result = await getInstance<GetServerDateTime>().call(param);
      return result.fold((left) {
        debugPrint(left.message);
        return null;
      }, (right) => right);
    } catch (e) {
      debugPrint('Error fetching time: $e');
      return DateTime.now();
    }
  }

  static bool isScrollTextActive(ScrollText scrollText) {
    if (!scrollText.status) return false;

    final scrollTimer = scrollText.scrollTimer;
    final now = DateTime(AppConstants.now.year, AppConstants.now.month,
        AppConstants.now.day, AppConstants.now.hour, AppConstants.now.minute);

    if (scrollText.scrollTimer.type == AppConstants.dateRangeOnly) {
      final startDate = DateTime(
          scrollTimer.startDate.year,
          scrollTimer.startDate.month,
          scrollTimer.startDate.day,
          scrollTimer.startTime.hour,
          scrollTimer.startTime.minute);
      final endDate = DateTime(
          scrollTimer.endDate.year,
          scrollTimer.endDate.month,
          scrollTimer.endDate.day,
          scrollTimer.endTime.hour,
          scrollTimer.endTime.minute);

      return now.isAfter(startDate) && now.isBefore(endDate);
    } else if (scrollText.scrollTimer.type == AppConstants.specificTimeRange) {
      final startTime = DateTime(now.year, now.month, now.day,
          scrollTimer.startTime.hour, scrollTimer.startTime.minute);
      final endTime = DateTime(now.year, now.month, now.day,
          scrollTimer.endTime.hour, scrollTimer.endTime.minute);

      return (now.isAfter(startTime) || now.isAtSameMomentAs(startTime)) &&
          (now.isBefore(endTime) || now.isAtSameMomentAs(endTime));
    } else {
      return false;
    }
  }

  static bool isContentActive(Content content) {
    if (!content.status) return false;
    final now = DateTime(AppConstants.now.year, AppConstants.now.month,
        AppConstants.now.day, AppConstants.now.hour, AppConstants.now.minute);
    if (content.playType == AppConstants.dateRangeOnly) {
      final startDate = DateTime(
          content.startDate.year,
          content.startDate.month,
          content.startDate.day,
          content.startTime.hour,
          content.startTime.minute);
      final endDate = DateTime(content.endDate.year, content.endDate.month,
          content.endDate.day, content.endTime.hour, content.endTime.minute);

      // print("""
      //   Content Info
      //   Name: ${content.name}
      //   startDate: ${content.startDate}
      //   endDate: ${content.endDate}
      //   startTime : ${content.startTime}
      //   endTime: ${content.endTime}
      //   Forceplay: ${content.forcePlay}
      //   Type: ${content.playType}
      //   Status: ${content.status}
      //   -------------------------------------------------
      //   ${AppConstants.dateRangeOnly}
      //   Start Date: $startDate
      //   End Date: $endDate
      //   Now: $now
      //   now.isAfter(startDate): ${now.isAfter(startDate)}
      //   now.isBefore(endDate): ${now.isBefore(endDate)}
      //   Returning ${now.isAfter(startDate) && now.isBefore(endDate)}
      //           -------------------------------------------------
      //                   -------------------------------------------------
      //   """);
      return now.isAfter(startDate) && now.isBefore(endDate);
    } else if (content.playType == AppConstants.specificTimeRange) {
      final startTime = DateTime(now.year, now.month, now.day,
          content.startTime.hour, content.startTime.minute);
      final endTime = DateTime(now.year, now.month, now.day,
          content.endTime.hour, content.endTime.minute);
      // print("""
      //   Content Info
      //   Name: ${content.name}
      //   startDate: ${content.startDate}
      //   endDate: ${content.endDate}
      //   startTime : ${content.startTime}
      //   endTime: ${content.endTime}
      //   Forceplay: ${content.forcePlay}
      //   Type: ${content.playType}
      //   Status: ${content.status}
      //   -------------------------------------------------
      //   ${AppConstants.specificTimeRange}
      //   Start Date: $startTime
      //   End Date: $endTime
      //   Now: $now
      //   now.isAfter(startTime): ${now.isAfter(startTime)}
      //   now.isAtSameMomentAs(startTime): ${now.isAtSameMomentAs(startTime)}
      //   now.isBefore(endTime): ${now.isBefore(endTime)}
      //   now.isAtSameMomentAs(endTime): ${now.isAtSameMomentAs(endTime)}
      //   Returning ${(now.isAfter(startTime) || now.isAtSameMomentAs(startTime)) && (now.isBefore(endTime) || now.isAtSameMomentAs(endTime))}
      //           -------------------------------------------------
      //                   -------------------------------------------------
      //   """);
      return (now.isAfter(startTime) || now.isAtSameMomentAs(startTime)) &&
          (now.isBefore(endTime) || now.isAtSameMomentAs(endTime));
    } else {
      return false;
    }
  }

  static void showErrSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: AppConstants.deviceWidth * 0.5,
        behavior: SnackBarBehavior.floating,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.error, color: ColorManager.white, size: 20),
            const SizedBox(width: 10),
            Text(
              message,
              style: const TextStyle(
                  color: ColorManager.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        backgroundColor: ColorManager.errorRed,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
