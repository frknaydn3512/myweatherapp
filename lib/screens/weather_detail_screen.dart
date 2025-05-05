import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import 'package:fl_chart/fl_chart.dart';

class WeatherDetailScreen extends StatefulWidget {
  final Weather weather;

  const WeatherDetailScreen({Key? key, required this.weather})
    : super(key: key);

  @override
  _WeatherDetailScreenState createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  Widget getWeatherIcon(int code) {
    switch (code) {
      case >= 200 && < 300:
        return Image.asset('assets/1.png');
      case >= 300 && < 400:
        return Image.asset('assets/2.png');
      case >= 500 && < 600:
        return Image.asset('assets/3.png');
      case >= 600 && < 700:
        return Image.asset('assets/4.png');
      case >= 700 && < 800:
        return Image.asset('assets/5.png');
      case == 800:
        return Image.asset('assets/6.png');
      case > 800 && <= 804:
        return Image.asset('assets/7.png');
      default:
        return Image.asset('assets/7.png');
    }
  }

  List<ForecastWeather> _forecastList = [];
  bool _isLoading = true;

  final Dio _dio = Dio();
  final String _apiKey = '07155427cc775958a854f0cf1273a415';

  @override
  void initState() {
    super.initState();
    fetchForecastData();
  }

  Future<void> fetchForecastData() async {
    final city = widget.weather.cityName;

    try {
      final response = await _dio.get(
        'https://api.openweathermap.org/data/2.5/forecast',
        queryParameters: {
          'q': city,
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'tr',
        },
      );

      final List<dynamic> list = response.data['list'];
      final Map<String, ForecastWeather> dailyForecastMap = {};

      for (var item in list) {
        final dateTime = DateTime.parse(item['dt_txt']);
        final dateKey = '${dateTime.year}-${dateTime.month}-${dateTime.day}';

        if (!dailyForecastMap.containsKey(dateKey) && dateTime.hour == 12) {
          dailyForecastMap[dateKey] = ForecastWeather.fromJson(item);
        }
      }

      setState(() {
        _forecastList = dailyForecastMap.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Hata: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = widget.weather;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(elevation: 0, title: Text('${weather.cityName} - Detay',style: TextStyle(color: Colors.amber),),backgroundColor: Colors.transparent,
),
      body: Stack(
        children: [

          Positioned(
            top: 80,
            left: 200,
            child: Container(
              height: 300,
              width: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple,
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: 200,
            child: Container(
              height: 300,
              width: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF673AB7),
              ),
            ),
          ),
          Positioned(
            top: 500,
            left: 50,
            right: 50,
            bottom: 100,
            child: Container(
              decoration: const BoxDecoration(color: Color(0xFFFFAB40)),
            ),
          ),


          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
            child: Container(color: Colors.transparent),
          ),


          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weather.cityName}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber
                          ),
                        ),
                        Text(
                          '${weather.description}, ${weather.temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(fontSize: 20,color: Colors.amber),
                        ),
                        const SizedBox(height: 20),

                        buildTemperatureChart(_forecastList),
                        const SizedBox(height: 40),
                        const Text(
                          '📅 5 Günlük Tahmin:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _forecastList.length,
                            itemBuilder: (context, index) {
                              final forecast = _forecastList[index];
                              return ListTile(
                                leading: getWeatherIcon(forecast.conditionCode),

                                title: Text(
                                  '${forecast.date.day}/${forecast.date.month} - ${forecast.description}',
                                ),
                                trailing: Text(
                                  '${forecast.temperature.round().toStringAsFixed(1)}°C',
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget buildTemperatureChart(List<ForecastWeather> forecasts) {
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 5,
            getDrawingHorizontalLine:
                (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
            getDrawingVerticalLine:
                (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < forecasts.length) {
                    final date = forecasts[index].date;
                    final temp = forecasts[index].temperature.round();
                    return Column(
                      children: [
                        Text(
                          '${date.day}/${date.month}',
                          style: const TextStyle(fontSize: 8),
                        ),
                        Text(
                          '$temp°',
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    );
                  }
                  return const Text('selam');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 5,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey, width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Colors.orange, Colors.deepOrange],
              ),
              barWidth: 4,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [Colors.orange.withOpacity(0.4), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              spots:
                  forecasts
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value.temperature))
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
