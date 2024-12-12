import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather/weather.dart';

import '../../../resources/asset_manager.dart';
import '../../../resources/constants.dart';
import '../../../services/utils.dart';

class WeatherWidget extends StatefulWidget {
  final double lat;
  final double long;
  final String language;
  final TextStyle textStyle;

  const WeatherWidget({
    super.key,
    required this.lat,
    required this.long,
    required this.language,
    required this.textStyle,
  });

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final _weatherFactory = WeatherFactory(AppConstants.weatherAPIkey);
  Weather? _weather;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _timer =
        Timer.periodic(const Duration(minutes: 15), (_) => _fetchWeather());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    final w =
        await _weatherFactory.currentWeatherByLocation(widget.lat, widget.long);
    setState(() => _weather = w);
  }

  Widget _buildShimmerImage() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 40,
        height: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildShimmerText() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 60,
        height: 20,
        color: Colors.white,
      ),
    );
  }

  Widget _buildWeatherIcon() {
    return _weather != null
        ? Image.asset(
            WeatherIcons.getWeatherIcon(_weather!.weatherIcon),
            height: 30,
            cacheHeight: 30,
          )
        : _buildShimmerImage();
  }

  Widget _buildTemperatureText() {
    return _weather != null
        ? Text(
            widget.language == "np"
                ? "${Utils.convertToNepaliNumbers(double.parse(_weather!.temperature!.celsius!.toStringAsFixed(2)))}°C"
                : "${_weather!.temperature!.celsius!.toStringAsFixed(2)}°C",
            style: widget.textStyle
                .copyWith(fontSize: 20, fontWeight: FontWeight.w500),
          )
        : _buildShimmerText();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildWeatherIcon(),
        const SizedBox(width: 10),
        _buildTemperatureText(),
      ],
    );
  }
}
