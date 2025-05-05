class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final int conditionCode;
  bool isDay(String iconCode) {
  return iconCode.contains('d');
}

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.conditionCode,
  });

  factory  Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
      conditionCode: json['weather'][0]['id'],
    );
  }
}