// lib/features/home/data/models/weather_model.dart
import '../../domain/entities/weather.dart';

class WeatherModel extends Weather {
  const WeatherModel({
    required super.temperature,
    required super.condition,
    required super.humidity,
    required super.aqi,
    required super.location,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['temperature'] as num).toDouble(),
      condition: json['condition'] as String,
      humidity: json['humidity'] as int,
      aqi: json['aqi'] as int,
      location: json['location'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'condition': condition,
      'humidity': humidity,
      'aqi': aqi,
      'location': location,
    };
  }
}