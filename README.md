# Masar
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Masar'),
          backgroundColor: Colors.red[900],
        ),
        body: Center(
          child: Image(
            image: NetworkImage('http://www.mediafire.com/convkey/e2ba/el3wqmiiftpv8p3zg.jpg'),
          ),
        ),
      ),
    ),
  );
}
