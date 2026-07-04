// lib/features/home/domain/entities/weather.dart
class Weather {
  final double temperature;
  final String condition;
  final int humidity;
  final int aqi; // Air Quality Index
  final String location;

  const Weather({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.aqi,
    required this.location,
  });
}