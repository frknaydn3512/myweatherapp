import '../models/weather_model.dart';
import 'package:dio/dio.dart';
import '../models/forecast_model.dart';

class WeatherService {
  final Dio _dio = Dio();
  final String _apiKey = '';
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Weather> fetchWeather(String cityName) async {
    final response = await _dio.get('$_baseUrl/weather', queryParameters: {
      'q': cityName,
      'appid': _apiKey,
      'units': 'metric',
      'lang': 'tr',
    });

    if (response.statusCode == 200) {
      return Weather.fromJson(response.data);
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  Future<List<ForecastWeather>> fetchForecast(String cityName) async {
    try {
      final response = await _dio.get('$_baseUrl/forecast', queryParameters: {
        'q': cityName,
        'appid': _apiKey,
        'units': 'metric',
      });

      if (response.statusCode == 200) {
        List<dynamic> list = response.data['list'];

        List<ForecastWeather> forecasts = [];
        for (int i = 0; i < list.length; i += 8) {
          forecasts.add(ForecastWeather.fromJson(list[i]));
        }

        return forecasts;
      } else {
        throw Exception('Forecast API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('fetchForecast error: $e');
      throw Exception('Tahmin verisi çekilemedi.');
    }
  }
}
