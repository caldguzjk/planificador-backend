import 'package:flutter/material.dart';
import 'trip_form.dart'; // Asegúrate de que trip_form.dart esté en lib/

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planificador de Viajes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TripFormPage(),
    );
  }
}
