import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:rentify/data/models/weather_data.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  WeatherData? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Request location permission
      var status = await Permission.location.request();

      if (status.isGranted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });

        // Get current position
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Fetch weather for current location
        await _fetchWeatherByCoordinates(position.latitude, position.longitude);
      } else {
        // Use default location if permission denied
        await _fetchWeatherByCity('Mumbai');
        setState(() {
          _errorMessage =
              'Location permission denied. Showing default location.';
        });
      }
    } catch (e) {
      // Use default location if an error occurs
      await _fetchWeatherByCity('Mumbai');
      setState(() {
        _errorMessage =
            'Could not determine location. Showing default location.';
      });
    }
  }

  Future<void> _fetchWeatherByCoordinates(double lat, double lon) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // For demo purposes, loading mock data
      await Future.delayed(Duration(seconds: 1));
      _loadSampleData();

      // In a real app, you would use this code with your API key:
      /*
      final apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
      final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weatherData = WeatherData.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch weather data. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
      */
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherByCity(String city) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // For demo purposes, loading mock data
      await Future.delayed(Duration(seconds: 1));
      _loadSampleData();

      // In a real app, you would use this code with your API key:
      /*
      final apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
      final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weatherData = WeatherData.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'City not found or other error occurred.';
          _isLoading = false;
        });
      }
      */
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _loadSampleData() {
    // Sample weather data for demonstration
    _weatherData = WeatherData(
      cityName: 'Mumbai',
      temperature: 18.5,
      description: 'Partly cloudy',
      iconCode: '02d',
      feelsLike: 17.8,
      humidity: 62,
      windSpeed: 5.2,
      lastUpdated: DateTime.now(),
      forecast: [
        DailyForecast(
          date: DateTime.now().add(Duration(days: 1)),
          minTemp: 15.2,
          maxTemp: 23.5,
          iconCode: '01d',
          description: 'Sunny',
        ),
        DailyForecast(
          date: DateTime.now().add(Duration(days: 2)),
          minTemp: 16.8,
          maxTemp: 24.2,
          iconCode: '02d',
          description: 'Partly cloudy',
        ),
        DailyForecast(
          date: DateTime.now().add(Duration(days: 3)),
          minTemp: 17.1,
          maxTemp: 25.0,
          iconCode: '10d',
          description: 'Light rain',
        ),
        DailyForecast(
          date: DateTime.now().add(Duration(days: 4)),
          minTemp: 16.5,
          maxTemp: 22.7,
          iconCode: '03d',
          description: 'Scattered clouds',
        ),
        DailyForecast(
          date: DateTime.now().add(Duration(days: 5)),
          minTemp: 15.0,
          maxTemp: 21.6,
          iconCode: '01d',
          description: 'Clear sky',
        ),
      ],
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2C2B34),
      appBar: AppBar(
        title: Text('Weather Forecast', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_errorMessage != null && _weatherData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    if (_weatherData == null) {
      return Center(
        child: Text(
          'No weather data available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _getCurrentLocation,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            _buildSearchBar(),
            SizedBox(height: 24),

            // Current weather
            _buildCurrentWeather(),
            SizedBox(height: 32),

            // Forecast
            Text(
              '5-Day Forecast',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 16),
            _buildForecast(),

            // Weather details
            SizedBox(height: 32),
            Text(
              'Weather Details',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 16),
            _buildWeatherDetails(),

            // Last updated
            SizedBox(height: 24),
            Center(
              child: Text(
                'Last updated: ${DateFormat('MMM d, y • h:mm a').format(_weatherData!.lastUpdated)}',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Icon(Icons.search),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  hintText: 'Search city...',
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _fetchWeatherByCity(value);
                  }
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                if (_cityController.text.isNotEmpty) {
                  _fetchWeatherByCity(_cityController.text);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeather() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.blue[700],
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _weatherData!.cityName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMMM d').format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Image.network(
                      'https://openweathermap.org/img/wn/${_weatherData!.iconCode}@2x.png',
                      width: 80,
                      height: 80,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.cloud,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _weatherData!.description.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_weatherData!.temperature.round()}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '°C',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              'Feels like ${_weatherData!.feelsLike.round()}°C',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecast() {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _weatherData!.forecast.length,
        itemBuilder: (context, index) {
          final forecast = _weatherData!.forecast[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.only(right: 12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(forecast.date),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Image.network(
                    forecast.getIconUrl(),
                    width: 40,
                    height: 40,
                    errorBuilder: (_, __, ___) => Icon(Icons.cloud, size: 30),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${forecast.maxTemp.round()}°',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${forecast.minTemp.round()}°',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherDetails() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildWeatherDetailItem(
              icon: Icons.water_drop,
              value: '${_weatherData!.humidity}%',
              label: 'Humidity',
            ),
            _buildWeatherDetailItem(
              icon: Icons.air,
              value: '${_weatherData!.windSpeed} m/s',
              label: 'Wind',
            ),
            _buildWeatherDetailItem(
              icon: Icons.visibility,
              value: '10 km',
              label: 'Visibility',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetailItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[700], size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
