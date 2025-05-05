class ForecastWeather {
  final DateTime date;
  final String description;
  final double temperature;
  final String iconCode;
  final int conditionCode;

  ForecastWeather({
    required this.date,
    required this.description,
    required this.temperature,
    required this.iconCode,
    required this.conditionCode
  });

  factory ForecastWeather.fromJson(Map<String, dynamic> json) {
    return ForecastWeather(
      date: DateTime.parse(json['dt_txt']),
      description: json['weather'][0]['description'],
      temperature: json['main']['temp'].toDouble(),
      iconCode: json['weather'][0]['icon'],
      conditionCode: json['weather'][0]['id'],
    );
  }
}
