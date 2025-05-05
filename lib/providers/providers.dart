import 'package:riverpod/riverpod.dart';

import '../models/weather_model.dart';
import '../services/weather_service.dart';

final weatherServiceProvider = Provider((ref) => WeatherService());

final cityWeatherProvider = FutureProvider.family<Weather, String>((
  ref,
  city,
) async {
  final service = ref.read(weatherServiceProvider);
  return service.fetchWeather(city);
});