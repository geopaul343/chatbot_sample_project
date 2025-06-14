
import 'package:flutter/material.dart';
import 'package:laennec_ai_health_assistant/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application. @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laennec AI Health Assistant',
     
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
      ),
      home: SplashScreen(),
    );
  }
}
