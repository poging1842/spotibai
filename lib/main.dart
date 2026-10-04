import 'package:flutter/material.dart';

import 'package:spotibai/screens/home_screen.dart';

void main() {
  runApp(const SpotibaiApp());
}

class SpotibaiApp extends StatelessWidget {
  const SpotibaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotibai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F2F4),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D6469),
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
