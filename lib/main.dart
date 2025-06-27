import 'package:flutter/material.dart';
import 'package:laennec_ai_assistant/screens/app_launcher.dart';

import 'package:laennec_ai_assistant/screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laennec AI Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home:  AppLauncher(),
    );
  }
}
