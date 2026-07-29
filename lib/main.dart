import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const AktivitasPklApp());
}

class AktivitasPklApp extends StatelessWidget {
  const AktivitasPklApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aktivitas PKL MU',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
