import 'package:demo_app/data/source/weather_api_service.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';

class LoginWeatherLoadingScreen extends StatefulWidget {
  const LoginWeatherLoadingScreen({Key? key}) : super(key: key);

  @override
  _LoginWeatherLoadingScreenState createState() => _LoginWeatherLoadingScreenState();
}

class _LoginWeatherLoadingScreenState extends State<LoginWeatherLoadingScreen> {
  String _weatherMessage = "Checking weather condition in Dhaka...";
  double? _temperature;
  String? _humidity;
  String? _windSpeed;
  String? _feelsLike;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final data = await serviceLocator<WeatherApiService>().getDhakaWeather();
      final List<dynamic> times = data['hourly']['time'];
      final List<dynamic> probabilities = data['hourly']['precipitation_probability'];
      final List<dynamic> temperatures = data['hourly']['temperature_2m'];
      final List<dynamic> humidities = data['hourly']['relative_humidity_2m'];
      final List<dynamic> apparentTemps = data['hourly']['apparent_temperature'];
      final List<dynamic> windSpeeds = data['hourly']['wind_speed_10m'];
      
      final now = DateTime.now();
      int currentHourIndex = 0;
      
      for (int i = 0; i < times.length; i++) {
        final time = DateTime.parse(times[i]);
        if (time.year == now.year && 
            time.month == now.month && 
            time.day == now.day && 
            time.hour == now.hour) {
          currentHourIndex = i;
          break;
        }
      }

      int rainHourIndex = -1;
      for (int i = currentHourIndex; i < probabilities.length && i < currentHourIndex + 72; i++) {
        if (probabilities[i] > 10) {
          rainHourIndex = i;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _temperature = (temperatures.length > currentHourIndex) 
              ? (temperatures[currentHourIndex] as num).toDouble() 
              : null;
          
          _humidity = '${humidities[currentHourIndex]}%';
          _windSpeed = '${windSpeeds[currentHourIndex]} km/h';
          _feelsLike = '${apparentTemps[currentHourIndex]}°C';

          if (rainHourIndex != -1) {
            final hoursFromNow = rainHourIndex - currentHourIndex;
            if (hoursFromNow == 0) {
              _weatherMessage = "It is likely raining or about to rain now";
            } else {
              _weatherMessage = "it may rain within $hoursFromNow hours";
            }
          } else {
            _weatherMessage = "No chance of rain within three days";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weatherMessage = "Could not fetch weather data";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 40),
            const Text(
              "Logging in...",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: Colors.blue, size: 18),
                      SizedBox(width: 4),
                      Text(
                        "DHAKA",
                        style: TextStyle(
                          fontSize: 16,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_temperature != null)
                    Text(
                      "${_temperature!.toStringAsFixed(1)}°C",
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: Colors.black87,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _weatherMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSmallDetail(Icons.water_drop_outlined, "Humid", _humidity ?? "--"),
                      _buildSmallDetail(Icons.air_outlined, "Wind", _windSpeed ?? "--"),
                      _buildSmallDetail(Icons.thermostat_outlined, "Feels", _feelsLike ?? "--"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.blue.shade300),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }
}
