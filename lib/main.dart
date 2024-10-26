import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Weather and Hotels',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String city = '';
  Map<String, dynamic>? data;

  Future<void> fetchData() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/'),
        body: {'city': city},
      );

      if (response.statusCode == 200) {
        setState(() {
          data = jsonDecode(response.body);
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResultScreen(data: data)),
        );
      } else {
        print('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather and Hotels'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              onChanged: (value) {
                city = value;
              },
              decoration: const InputDecoration(
                hintText: 'Enter city name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                fetchData();
              },
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic>? data;

  const ResultScreen({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Result'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            data != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Weather Information',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('City: ${data!['weather']['city']}'),
                      Text('Country: ${data!['weather']['country']}'),
                      Text(
                          'Temperature: ${data!['weather']['temp_celsius']}°C'),
                      Text('Weather: ${data!['weather']['weather']}'),
                      const Text('Forecast:'),
                      
                      Text(
                          '3 hrs later: ${data!['weather']['forecast']['3']}°C'
                          ),
                      Text(
                          '6 hrs later: ${data!['weather']['forecast']['6']}°C'
                          ),
                      Text(
                          '9 hrs later: ${data!['weather']['forecast']['9']}°C'
                          ),
                    ],
                  )
                : const SizedBox(),
            const SizedBox(height: 20),
            data != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hotel Information',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      if (data!['hotels'] != 'Error fetching hotel data')
                        for (var hotel in data!['hotels'])
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${hotel['Name']}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text('${hotel['Area']}'),
                              
                              ElevatedButton(
                                onPressed: () {
                                  launchUrl(Uri.parse('${hotel['Link']}'));
                                },
                                child: const Text('Link'),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                      if (data!['hotels'] == 'Error fetching hotel data')
                        Text('No Data Available')
                    ],
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
