// home_screen.dart
import 'dart:ui';
import 'package:demo111/services/location_helper.dart';
import 'package:demo111/providers/providers.dart';
import 'package:demo111/screens/weather_detail_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Color getWeatherColor(int conditionCode) {
    if (conditionCode >= 200 && conditionCode < 300) {
      return Colors.deepPurple.shade100; // Fırtına
    } else if (conditionCode >= 300 && conditionCode < 500) {
      return Colors.lightBlue.shade100; // Çiseleme
    } else if (conditionCode >= 500 && conditionCode < 600) {
      return Colors.blue.shade100; // Yağmurlu
    } else if (conditionCode >= 600 && conditionCode < 700) {
      return Colors.grey.shade300; // Karlı
    } else if (conditionCode == 800) {
      return Colors.orange.shade100; // Açık hava
    } else if (conditionCode > 800 && conditionCode <= 804) {
      return Colors.grey.shade200; // Bulutlu
    } else {
      return Colors.white; // Varsayılan
    }
  }

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

  final TextEditingController _controller = TextEditingController();
  List<String> searchedCities = [];

  String? currentCity;

  final Map<String, String> cityBackgrounds = {
    'izmir': 'assets/izmir.jpg',
    'istanbul': 'assets/istanbul.jpeg',
    'ankara': 'assets/ankara.jpg',

  };

  @override
  void initState() {
    super.initState();
    _loadCurrentLocationWeather();
  }

  Future<void> _loadCurrentLocationWeather() async {
    final city = await getCurrentCityName();
    if (city != null) {
      setState(() {
        currentCity = city;
      });
    }
  }

  void _searchCity() {
    final city = _controller.text.trim();
    if (city.isNotEmpty && !searchedCities.contains(city)) {
      setState(() {
        searchedCities.add(city);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> allCities = [
      if (currentCity != null) currentCity!,
      'Izmır',
      'Istanbul',
      'Ankara',
      ...searchedCities.where((c) => c != currentCity),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Hava Durumu App",
          style: TextStyle(color: Colors.amber),
        ),

        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
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
              height: 200,
              decoration: const BoxDecoration(color: Color(0xFFFFAB40)),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
            child: Container(color: Colors.transparent),
          ),


          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              1.5 * kToolbarHeight,
              20,
              10,
            ),
            child: Column(
              children: [

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Şehir ara...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _searchCity,
                      child: const Icon(Icons.search),
                    ),
                  ],
                ),
                const SizedBox(height: 20),


                Expanded(
                  child: ListView.builder(
                    itemCount: allCities.length,
                    itemBuilder: (context, index) {
                      final city = allCities[index];
                      final weatherAsyncValue = ref.watch(
                        cityWeatherProvider(city),
                      );

                      return weatherAsyncValue.when(
                        data: (weather) {
                          final cityKey = weather.cityName.toLowerCase();
                          final backgroundImage = cityBackgrounds[cityKey];

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration:
                                backgroundImage != null
                                    ? BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(backgroundImage),
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black.withOpacity(0.3),
                                          BlendMode.darken,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    )
                                    : BoxDecoration(
                                      color: getWeatherColor(
                                        weather.conditionCode,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                            child: ListTile(
                              leading: getWeatherIcon(weather.conditionCode),
                              title: Text(
                                weather.cityName,
                                style: TextStyle(
                                  color:
                                      backgroundImage != null
                                          ? Colors.white
                                          : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${weather.description}, ${weather.temperature.round()}°C',
                                style: TextStyle(
                                  color:
                                      backgroundImage != null
                                          ? Colors.white70
                                          : Colors.black87,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => WeatherDetailScreen(
                                          weather: weather,
                                        ),
                                  ),
                                );
                              },
                            ),
                          );
                        },

                        loading:
                            () => const Card(
                              child: ListTile(
                                title: Text('Yükleniyor...'),
                                trailing: CircularProgressIndicator(),
                                enabled: false,
                              ),
                            ),
                        error:
                            (error, _) => const Card(
                              child: ListTile(
                                title: Text('Veri alınamadı'),
                                subtitle: Text(
                                  'Hava durumu verisi getirilemedi.',
                                ),
                                enabled: false,
                              ),
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
}
