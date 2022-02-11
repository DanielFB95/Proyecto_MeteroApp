import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_meteroapp/utils/constant.dart';
import 'package:flutter_meteroapp/models/weather_response.dart';
import 'package:flutter_meteroapp/utils/preferences.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<WeatherResponse> weatherResponse;
  late double? lat = 0;
  late double? long = 0;

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init().then((value) {
      if (lat == null || long == null) {
        PreferenceUtils.setDouble(LAT, 38);
        PreferenceUtils.setDouble(LONG, -4);
      }
    });

    weatherResponse = fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return _printWeatherCountry();
  }

  Future<WeatherResponse> fetchWeather() async {
    lat = PreferenceUtils.getDouble(LAT);
    long = PreferenceUtils.getDouble(LONG);
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/onecall?appid=$API_KEY&lat=' +
            lat.toString() +
            '&lon=' +
            long.toString() +
            '&units=metric'));
    if (response.statusCode == 200) {
      return WeatherResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load location');
    }
  }

  Widget _printWeatherCountry() {
    return FutureBuilder<WeatherResponse>(
      future: fetchWeather(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _fetchWeather(snapshot.data!);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _fetchWeather(WeatherResponse weatherResponse) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: 500,
            height: 450,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/fondo1.jpg'), fit: BoxFit.cover)),
            child: Column(
              children: [
                const Padding(padding: EdgeInsets.only(top: 65)),
                Text(
                  weatherResponse.timezone.toString(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
                const Padding(padding: EdgeInsets.only(top: 30)),
                Image.network(
                    'http://openweathermap.org/img/wn/${weatherResponse.current.weather.elementAt(0).icon}@2x.png'),
                const Padding(padding: EdgeInsets.only(top: 30)),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.thermostat,
                        color: Colors.white,
                        size: 50,
                      ),
                      Text(
                        weatherResponse.current.temp.toString() + ' Cº',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 30),
                      ),
                      const Padding(padding: EdgeInsets.only(right: 15)),
                      const Icon(
                        Icons.air,
                        color: Colors.white,
                        size: 50,
                      ),
                      Text(
                        weatherResponse.current.windSpeed.toString() + ' m/s',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    ],
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 10)),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(right: 0)),
                      SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset(
                            'assets/humedad.png',
                            color: Colors.white,
                          )),
                      Text(
                        ' ' +
                            weatherResponse.current.humidity.toString() +
                            ' %',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 30),
                      ),
                      const Padding(padding: EdgeInsets.only(left: 55)),
                      SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset(
                            'assets/lloviendo.png',
                            color: Colors.white,
                          )),
                      Text(
                        ' ' +
                            weatherResponse.minutely
                                .elementAt(0)
                                .precipitation
                                .toString() +
                            ' cm',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 500,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 5),
                  child: Text(
                    'Tiempo por horas',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                _weatherHours(weatherResponse.hourly),
                const Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 5),
                  child: Text('Tiempo por días',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 30,
                          fontWeight: FontWeight.bold)),
                ),
                _weatherDays(weatherResponse.daily)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherHours(List<Hourly> listaHoras) {
    return SizedBox(
      width: 500,
      height: 140,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: listaHoras.length,
          itemBuilder: (context, index) {
            return _horas(listaHoras.elementAt(index));
          }),
    );
  }

  Widget _horas(Hourly horas) {
    String date =
        DateTime.fromMillisecondsSinceEpoch(horas.dt * 1000).toString();
    List<String> listaFechas = date.split(' ');
    List<String> hora = listaFechas[1].split('.');
    String h = hora[0];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(),
            borderRadius: const BorderRadius.all(Radius.circular(30))),
        width: 125,
        height: 175,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(
              child: Text(
                h.toString(),
                style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: ListTile(
                title: Image.network(
                  'http://openweathermap.org/img/wn/${horas.weather.elementAt(0).icon}@2x.png',
                  width: 50,
                  height: 50,
                ),
                subtitle: Center(
                  child: Text(
                    horas.temp.toString() + ' Cº',
                    style: const TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weatherDays(List<Daily> listaDias) {
    return SizedBox(
      width: 500,
      height: 275,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: listaDias.length,
        itemBuilder: (context, index) {
          return _dias(listaDias.elementAt(index));
        },
      ),
    );
  }

  Widget _dias(Daily dias) {
    String date =
        DateTime.fromMillisecondsSinceEpoch(dias.dt * 1000).toString();
    List<String> listaFechas = date.split(' ');
    String dia = listaFechas[0];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 275,
        height: 500,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(),
            borderRadius: const BorderRadius.all(Radius.circular(30))),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(
              child: Text(
                dia.toString(),
                style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Image.network(
                'http://openweathermap.org/img/wn/${dias.weather.elementAt(0).icon}@2x.png',
                width: 100,
                height: 100,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Media           ' + dias.temp.day.toString() + ' Cº',
                  style: const TextStyle(fontSize: 20, color: Colors.black54),
                ),
                Row(
                  children: [
                    Text(
                      'Max.             ' + dias.temp.max.toString() + ' Cº',
                      style:
                          const TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                  ],
                ),
                Text(
                  'Min.              ' + dias.temp.min.toString() + ' Cº',
                  style: const TextStyle(fontSize: 20, color: Colors.black54),
                ),
                Text(
                  'Humedad        ' + dias.humidity.toString() + ' %',
                  style: const TextStyle(fontSize: 20, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
