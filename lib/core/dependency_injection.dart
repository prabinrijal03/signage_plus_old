import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:screen_brightness_util/screen_brightness_util.dart';
import 'package:slashplus/data/usecases/fetch_feedback_questions.dart';
import 'package:slashplus/data/usecases/generate_token.dart';
import 'package:slashplus/data/usecases/get_server_datetime.dart';
import 'package:slashplus/data/usecases/submit_feedback_answer.dart';
import 'package:slashplus/resources/constants.dart';

import '../data/datasource/local_datasource.dart';
import '../data/datasource/remote_datasource.dart';
import '../data/repositories/repository.dart';
import '../data/usecases/check_device_id.dart';
import '../data/usecases/download_video.dart';
import '../data/usecases/fetch_condition.dart';
import '../data/usecases/fetch_contents.dart';
import '../data/usecases/fetch_custom_user.dart';
import '../data/usecases/fetch_device_layout.dart';
import '../data/usecases/fetch_scrolling_texts.dart';
import '../data/usecases/fetch_ward_info.dart';
import '../data/usecases/login_device.dart';
import '../data/usecases/set_version.dart';
import '../services/hive_services.dart';
import '../services/screen_brightness.dart';
import 'network/dio_factory.dart';
import 'network/internet_checker.dart';

final getInstance = GetIt.instance;

class DependencyInjection {
  static void initAppModule() {
    getInstance.registerLazySingleton<NetworkInfo>(
        () => NetworkInfoImpl(InternetConnection()));
    getInstance.registerLazySingleton<ScreenBrightness>(
        () => ScreenBrightnessImpl(ScreenBrightnessUtil()));

    getInstance.registerLazySingleton<DioFactory>(() => DioFactory());
    final dio = getInstance<DioFactory>().getDio(UrlConstants.baseUrl);
    final counterDio =
        getInstance<DioFactory>().getDio(UrlConstants.tokenBaseVersionUrl);

    getInstance.registerLazySingleton<HiveService>(() => HiveService());

    getInstance.registerLazySingleton<RemoteDatasource>(
        () => RemoteDatasourceImpl(dio, counterDio));
    getInstance.registerLazySingleton<LocalDatasource>(
        () => LocalDatasourceImpl(getInstance<HiveService>()));
    getInstance.registerLazySingleton<Repository>(
        () => RepositoryImpl(getInstance(), getInstance(), getInstance()));

    // USECASES
    getInstance.registerLazySingleton<GetServerDateTime>(
        () => GetServerDateTime(getInstance()));
    getInstance
        .registerLazySingleton<LoginDevice>(() => LoginDevice(getInstance()));
    getInstance.registerLazySingleton<FetchDeviceLayout>(
        () => FetchDeviceLayout(getInstance()));
    getInstance.registerLazySingleton<FetchScrollingTexts>(
        () => FetchScrollingTexts(getInstance()));
    getInstance.registerLazySingleton<FetchContents>(
        () => FetchContents(getInstance()));
    getInstance.registerLazySingleton<Donwload>(() => Donwload(getInstance()));
    getInstance.registerLazySingleton<FetchCustomUser>(
        () => FetchCustomUser(getInstance()));
    getInstance.registerLazySingleton<FetchCondition>(
        () => FetchCondition(getInstance()));
    getInstance.registerLazySingleton<FetchWardDetails>(
        () => FetchWardDetails(getInstance()));
    getInstance
        .registerLazySingleton<SetVersion>(() => SetVersion(getInstance()));
    getInstance.registerLazySingleton<CheckDeviceId>(
        () => CheckDeviceId(getInstance()));
    getInstance.registerLazySingleton<FetchFeedbackQuestions>(
        () => FetchFeedbackQuestions(getInstance()));
    getInstance.registerLazySingleton<SubmitFeedbackAnswer>(
        () => SubmitFeedbackAnswer(getInstance()));
    getInstance.registerLazySingleton<GenerateToken>(
        () => GenerateToken(getInstance()));
  }

  static Future<void> reset() async {
    await getInstance.reset(dispose: true);
    initAppModule();
  }
}
