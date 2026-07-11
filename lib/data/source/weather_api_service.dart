import 'package:dio/dio.dart';

class WeatherApiService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> getDhakaWeather() async {
    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': 23.8103,
          'longitude': 90.4125,
          'hourly': 'precipitation_probability,temperature_2m,relative_humidity_2m,apparent_temperature,uv_index,visibility,surface_pressure,wind_speed_10m,wind_direction_10m',
          'forecast_days': 3,
          'timezone': 'auto',
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
