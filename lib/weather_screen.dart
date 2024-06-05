import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {

  late Future<Map<String, dynamic>> weather;

  Future<Map<String, dynamic>> getCurrentWeather() async{
    try {
      String cityName = "London";
      final res = await http.get(
        Uri.parse('http://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey'),
      );

      final data = jsonDecode(res.body);

      if(data['cod'] != '200'){
        throw 'An unexpected error occurred';
      }

      return data;

    }catch(e){
      throw e.toString();
    }
  }
  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App", style: TextStyle(
          fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
         IconButton(
          onPressed: (){
            setState(() {
              weather = getCurrentWeather();
            });
          }, 
          icon: const Icon(Icons.refresh),
        ),
        ],
      ),
      
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if(snapshot.hasError){
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;

          final currentWeatherData = data['list'][0];

          final currentTemp = currentWeatherData['main']['temp'];
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];

          return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //main card
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text('$currentTemp K', style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
        
                            Icon(
                              currentSky == 'Clouds' || currentSky == 'Rain' ? Icons.cloud : Icons.sunny, 
                              size: 60
                            ),
        
                            const SizedBox(height: 16),
        
                            Text(currentSky, 
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          
              const SizedBox(height: 20,),
        
              //Weather forcast card
              const Text("Hourly Forcast", style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
               ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder( 
                  scrollDirection: Axis.horizontal,  //listView builder have a tendency to taken the entire screen
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final hourlyForecast = data['list'][index + 1];
                    final hourlySky = data['list'][index + 1]['weather'][0]['main'];
                    final time = DateTime.parse(hourlyForecast['dt_txt'].toString());
                    return HourlyForecastItem(
                      time: DateFormat.j().format(time), 
                      icon: hourlySky == 'Clouds' || hourlySky  == 'Rain'? Icons.cloud : Icons.sunny, 
                      temp: hourlyForecast['main']['temp'].toString(),
                    );
                  }
                ),
              ),
              const SizedBox(height: 20,),
        
              //Additional info card
              const Text("Additional Information", style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
               ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AdditinaolInfoItem(
                    icon: Icons.water_drop,
                    label: "Humidity",
                    value: currentHumidity.toString(),
                  ),
                  AdditinaolInfoItem(
                    icon: Icons.air,
                    label: "Wind speed",
                    value: currentWindSpeed.toString(),
                  ),
                  AdditinaolInfoItem(
                    icon: Icons.beach_access,
                    label: "Pressure",
                    value: currentPressure.toString(),
                  ), 
                ],
              ),
            ],
          ),
        );
        },
      ) 
    );
  }
}
