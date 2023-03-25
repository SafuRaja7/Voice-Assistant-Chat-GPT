import 'package:chat_gpt_flutter/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice Assistant Chat Gpt',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}
