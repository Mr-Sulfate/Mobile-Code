import 'package:flutter/material.dart';
import 'package:mobile_labs/domain/study_plan.dart';
import 'package:mobile_labs/screens/home_screen.dart';

class MobileLabsApp extends StatelessWidget {
  const MobileLabsApp({super.key, this.service = const StudyPlanService()});

  final StudyPlanService service;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46E5),
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Лабораторная работа 1',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7FC),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
        ),
      ),
      home: HomeScreen(service: service),
    );
  }
}
