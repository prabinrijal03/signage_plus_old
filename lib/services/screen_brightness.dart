import 'package:screen_brightness_util/screen_brightness_util.dart';

abstract class ScreenBrightness {
  Future<double> get screenBrightness;
  void setScreenBrightness(double brightness);
}

class ScreenBrightnessImpl implements ScreenBrightness {
  final ScreenBrightnessUtil screenBrightnessUtil;

  ScreenBrightnessImpl(this.screenBrightnessUtil);

  @override
  Future<double> get screenBrightness => screenBrightnessUtil.getBrightness();

  @override
  void setScreenBrightness(double brightness) => screenBrightnessUtil.setBrightness(brightness);
}
