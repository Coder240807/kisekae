import 'package:flutter/material.dart';
import 'package:kisekae/getting_started.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kisekae',
      theme: ThemeData(),
      debugShowCheckedModeBanner: false,
      home: const GettingStartedScreen(),
    );
  }
}
