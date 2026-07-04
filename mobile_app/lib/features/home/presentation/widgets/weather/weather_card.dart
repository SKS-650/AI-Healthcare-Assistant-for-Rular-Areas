import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/weather.dart';

class WeatherCard extends StatelessWidget {
  final Weather weather;
  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B47E8), Color(0xFF4F94FF), Color(0xFF18C8C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.primary.withValues(alpha: 0.30),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18, top: -18,
            child: Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.location_on_rounded,
                            color: Colors.white70, size: 13),
                        const SizedBox(width: 4),
                        Text(weather.location,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${weather.temperature}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 52,
                                  fontWeight: FontWeight.w900,
                                  height: 1.0,
                                  letterSpacing: -2)),
                          const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text('°C',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(weather.condition,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _Pill(icon: '💨', label: 'AQI ${weather.aqi}',
                        color: _aqiColor(weather.aqi)),
                    const SizedBox(height: 8),
                    _Pill(icon: '💧', label: '${weather.humidity}%',
                        color: Colors.white.withValues(alpha: 0.20)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🌱', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Text(_healthAdvice(weather.aqi),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _aqiColor(int aqi) {
    if (aqi <= 50) return DesignTokens.green.withValues(alpha: 0.4);
    if (aqi <= 100) return DesignTokens.yellow.withValues(alpha: 0.4);
    if (aqi <= 150) return DesignTokens.orange.withValues(alpha: 0.4);
    return DesignTokens.danger.withValues(alpha: 0.4);
  }

  String _healthAdvice(int aqi) {
    if (aqi <= 50) return 'Good air';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Sensitive';
    return 'Unhealthy';
  }
}

class _Pill extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  const _Pill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
