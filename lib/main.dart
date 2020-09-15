import 'package:flutter/material.dart';
import 'package:masar/screens/maptest.dart';
import 'screens/loading_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masar',

      home: SafeArea(
        child: Scaffold(
          body: MapSample()
        ),
      ),
    );
  }
}

