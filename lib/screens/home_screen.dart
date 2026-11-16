import 'step_sensor_test_screen.dart';

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color background = Color(0xFFF8F7F3);
  static const Color primary = Color(0xFF3F6651);
  static const Color darkText = Color(0xFF25332E);
  static const Color secondaryText = Color(0xFF66736C);
  static const Color lightGreen = Color(0xFFE4EDE5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR LITTLE MOVEMENT BREAK',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Hey, adventurer! 👋',
                          style: TextStyle(
                            color: darkText,
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 23,
                    backgroundColor: lightGreen,
                    child: Icon(Icons.eco_rounded, color: primary),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Spud mascot card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Meet Spud!',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Temporary mascot built with Flutter
                    const SpudMascot(),

                    const SizedBox(height: 22),

                    const Text(
                      '"I\'ve been sitting all day. Help!"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Help Spud explore the world by '
                      'completing short movement challenges.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Adventure button
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StepSensorTestScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Start Adventure',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward_rounded),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Information card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE4E9E2)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.directions_walk_rounded, color: primary),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Small steps, big adventures',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Take a short break from studying. '
                      'Move your body and unlock '
                      'Spud\'s next destination.',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              const Center(
                child: Text(
                  'No pressure. No streaks. Just movement.',
                  style: TextStyle(color: secondaryText, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple Spud character drawn using Flutter widgets.
// We can replace this with our final mascot asset later.
class SpudMascot extends StatelessWidget {
  const SpudMascot({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 175,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sprout
          Positioned(
            top: 2,
            left: 84,
            child: Transform.rotate(
              angle: -0.5,
              child: const Icon(
                Icons.eco_rounded,
                size: 47,
                color: Color(0xFF77A889),
              ),
            ),
          ),

          // Potato body
          Positioned(
            top: 38,
            child: Container(
              width: 135,
              height: 125,
              decoration: BoxDecoration(
                color: const Color(0xFFF3C879),
                borderRadius: BorderRadius.circular(55),
                border: Border.all(color: const Color(0xFFB98A46), width: 2),
              ),
              child: Stack(
                children: [
                  // Eyes
                  const Positioned(
                    top: 43,
                    left: 37,
                    child: CircleAvatar(
                      radius: 5,
                      backgroundColor: Color(0xFF25332E),
                    ),
                  ),
                  const Positioned(
                    top: 43,
                    right: 37,
                    child: CircleAvatar(
                      radius: 5,
                      backgroundColor: Color(0xFF25332E),
                    ),
                  ),

                  // Smile
                  const Positioned(
                    top: 65,
                    left: 54,
                    child: Icon(
                      Icons.sentiment_satisfied_alt_rounded,
                      color: Color(0xFF25332E),
                      size: 27,
                    ),
                  ),

                  // Cheeks
                  Positioned(
                    top: 65,
                    left: 20,
                    child: Container(
                      width: 19,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9A78E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 65,
                    right: 20,
                    child: Container(
                      width: 19,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9A78E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
