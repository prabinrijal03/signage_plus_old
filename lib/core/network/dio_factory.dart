import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../resources/constants.dart';
import '../../services/hive_services.dart';

class DioFactory {
  Dio getDio(String baseUrl) {
    Dio dio = Dio();
    final String? accessToken = HiveService().getAccessToken();
    final String? deviceCode = HiveService.getTokenDeviceCode();

    dio.options = BaseOptions(
      baseUrl: baseUrl,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        if (accessToken != null) "Authorization": "Bearer $accessToken",
        if (deviceCode != null) "x-device-code": deviceCode,
      },
      connectTimeout: const Duration(seconds: AppConstants.connectionTimeOutSeconds),
      receiveTimeout: const Duration(seconds: AppConstants.connectionTimeOutSeconds),
    );

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        error: true,
        request: true,
        compact: true,
        responseBody: true,
        logPrint: (object) {
          // print(object);
        },
      ),
    );

    return dio;
  }
}
