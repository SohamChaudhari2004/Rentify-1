class WeatherData {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final DateTime lastUpdated;
  final List<DailyForecast> forecast;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.lastUpdated,
    required this.forecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    List<DailyForecast> forecastList = [];
    if (json.containsKey('daily')) {
      forecastList = List<DailyForecast>.from(
          json['daily'].map((x) => DailyForecast.fromJson(x)));
    }

    return WeatherData(
      cityName: json['name'] ?? 'Unknown Location',
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      iconCode: json['weather'][0]['icon'] ?? '01d',
      feelsLike: (json['main']['feels_like'] ?? 0).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      lastUpdated: DateTime.now(),
      forecast: forecastList,
    );
  }

  String getIconUrl() {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }
}

class DailyForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String iconCode;
  final String description;

  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.iconCode,
    required this.description,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      minTemp: (json['temp']['min'] ?? 0).toDouble(),
      maxTemp: (json['temp']['max'] ?? 0).toDouble(),
      iconCode: json['weather'][0]['icon'] ?? '01d',
      description: json['weather'][0]['description'] ?? '',
    );
  }

  String getIconUrl() {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }
}
