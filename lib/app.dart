import 'package:flutter/material.dart';
import 'package:mobile_labs/screens/home_screen.dart';

class MobileLabsApp extends StatelessWidget {
  const MobileLabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Лабораторная работа 1',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}
