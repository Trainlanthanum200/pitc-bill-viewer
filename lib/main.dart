import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MepcoApp());
}

class MepcoApp extends StatelessWidget {
  const MepcoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: kPrimary,
        scaffoldBackgroundColor: kBg,
      ),
      home: const SplashScreen(),
    );
  }
}
