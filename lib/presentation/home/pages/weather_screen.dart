import 'package:demo_app/data/source/weather_api_service.dart';
import 'package:demo_app/service_locator.dart';
import 'package:flutter/material.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _weatherMessage = "Checking weather condition in Dhaka...";
  double? _temperature;
  Map<String, dynamic>? _extraDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() => _isLoading = true);
    try {
      final data = await serviceLocator<WeatherApiService>().getDhakaWeather();
      final List<dynamic> times = data['hourly']['time'];
      final List<dynamic> probabilities = data['hourly']['precipitation_probability'];
      final List<dynamic> temperatures = data['hourly']['temperature_2m'];
      final List<dynamic> humidities = data['hourly']['relative_humidity_2m'];
      final List<dynamic> apparentTemps = data['hourly']['apparent_temperature'];
      final List<dynamic> uvIndices = data['hourly']['uv_index'];
      final List<dynamic> visibilities = data['hourly']['visibility'];
      final List<dynamic> pressures = data['hourly']['surface_pressure'];
      final List<dynamic> windSpeeds = data['hourly']['wind_speed_10m'];
      final List<dynamic> windDirections = data['hourly']['wind_direction_10m'];

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

          _extraDetails = {
            'Humidity': '${humidities[currentHourIndex]}%',
            'Feels Like': '${apparentTemps[currentHourIndex]}°C',
            'UV Index': '${uvIndices[currentHourIndex]}',
            'Visibility': '${(visibilities[currentHourIndex] / 1000).toStringAsFixed(1)} km',
            'Pressure': '${pressures[currentHourIndex]} hPa',
            'Wind Speed': '${windSpeeds[currentHourIndex]} km/h',
            'Wind Dir': '${windDirections[currentHourIndex]}°',
            'Rain Chance': '${probabilities[currentHourIndex]}%',
          };

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
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weatherMessage = "Could not fetch weather data";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather Forecast"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchWeather,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildWeatherCard(),
                        const SizedBox(height: 24),
                        _buildDetailsGrid(),
                        const SizedBox(height: 24),
                        _buildInfoSection(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                "DHAKA",
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_temperature != null)
            Text(
              "${_temperature!.toStringAsFixed(1)}°C",
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w200,
                color: Colors.black87,
              ),
            ),
          const SizedBox(height: 12),
          Text(
            _weatherMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Icon(
            _weatherMessage.contains("No chance") ? Icons.wb_sunny_rounded : Icons.umbrella_rounded,
            size: 56,
            color: _weatherMessage.contains("No chance") ? Colors.orange : Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid() {
    if (_extraDetails == null) return const SizedBox();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: _extraDetails!.length,
      itemBuilder: (context, index) {
        String key = _extraDetails!.keys.elementAt(index);
        String value = _extraDetails![key];
        return _buildDetailItem(key, value, _getIconForKey(key));
      },
    );
  }

  Widget _buildDetailItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForKey(String key) {
    switch (key) {
      case 'Humidity': return Icons.water_drop_outlined;
      case 'Feels Like': return Icons.thermostat_outlined;
      case 'UV Index': return Icons.wb_sunny_outlined;
      case 'Visibility': return Icons.visibility_outlined;
      case 'Pressure': return Icons.compress_outlined;
      case 'Wind Speed': return Icons.air_outlined;
      case 'Wind Dir': return Icons.explore_outlined;
      case 'Rain Chance': return Icons.umbrella_outlined;
      default: return Icons.info_outline;
    }
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              "Weather data is fetched for the next 72 hours to help you plan your pump usage.",
              style: TextStyle(color: Colors.blueGrey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
