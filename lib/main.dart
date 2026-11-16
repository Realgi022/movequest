
import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const MoveQuestApp());
}

class MoveQuestApp extends StatelessWidget {
  const MoveQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoveQuest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F6651),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F7F3),
      ),
      home: const WelcomeScreen(),
    );
  }
}
