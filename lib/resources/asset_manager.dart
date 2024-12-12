const imagePath = 'assets/images';
const weatherIconPath = 'assets/icons';

class SvgAssets {
  static const String logo = '$imagePath/logo.svg';
}

class WeatherIcons {
  static Map<String, String> mapWeatherIcons = {
    "03d": "04d",
    "03n": "04d",
    "04n": "04d",
    "09d": "10d",
    "09n": "10d",
    "10n": "10d",
    "11n": "11d",
    "13n": "13d",
    "50n": "50d",
  };

  static String getWeatherIcon(String? icon) {
    if (icon == null) return weatherIcon('01d');

    if (mapWeatherIcons.containsKey(icon)) {
      return weatherIcon(mapWeatherIcons[icon]!);
    } else {
      return weatherIcon(icon);
    }
  }

  static String weatherIcon(String icon) => '$weatherIconPath/$icon.png';
}
