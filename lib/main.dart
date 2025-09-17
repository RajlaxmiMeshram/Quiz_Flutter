import 'package:flutter/material.dart';
import 'package:qr_scanner/screens/start_screen.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 103, 57, 181),
              Color.fromARGB(255, 43, 26, 73)
            ],
          ),
          
        ),
        child: const StartScreen(),
      ),
    ),
  ));
}
