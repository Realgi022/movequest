
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sleepy_forest_screen.dart';

class AdventureMapScreen extends StatefulWidget {
  const AdventureMapScreen({super.key});

  @override
  State<AdventureMapScreen> createState() =>
      _AdventureMapScreenState();
}

class _AdventureMapScreenState extends State<AdventureMapScreen> {
  static const Color background = Color(0xFFF8F7F3);
  static const Color primary = Color(0xFF3F6651);
  static const Color darkText = Color(0xFF25332E);
  static const Color secondaryText = Color(0xFF66736C);
  static const Color lightGreen = Color(0xFFE4EDE5);

  bool _forestCompleted = false;
  bool _loadingProgress = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final completed =
          preferences.getBool('sleepy_forest_completed') ?? false;

      if (!mounted) return;

      setState(() {
        _forestCompleted = completed;
        _loadingProgress = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadingProgress = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load saved progress.'),
        ),
      );
    }
  }

  Future<void> _openSleepyForest() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SleepyForestScreen(),
      ),
    );

    if (!mounted) return;

    // Refresh progress when the player returns.
    await _loadProgress();
  }

  void _showComingSoon(String location) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$location is coming soon! Spud is packing. 🥔',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Adventure Map',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Where to, adventurer?',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose a destination and help Spud explore '
                'the world, one step at a time.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: secondaryText,
                ),
              ),
              const SizedBox(height: 24),

              // Decorative world map
              Container(
                width: double.infinity,
                height: 170,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      top: 20,
                      left: 25,
                      child: Icon(
                        Icons.park_rounded,
                        size: 62,
                        color: Color(0xFF78A786),
                      ),
                    ),
                    const Positioned(
                      top: 45,
                      right: 30,
                      child: Icon(
                        Icons.landscape_rounded,
                        size: 78,
                        color: Color(0xFF7F9C85),
                      ),
                    ),
                    const Positioned(
                      bottom: 20,
                      left: 105,
                      child: Icon(
                        Icons.route_rounded,
                        size: 65,
                        color: primary,
                      ),
                    ),
                    const Center(
                      child: Icon(
                        Icons.explore_rounded,
                        size: 48,
                        color: primary,
                      ),
                    ),
                    Positioned(
                      bottom: 14,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Spud\'s World 🥔',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Explore locations',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                  ),
                  if (_forestCompleted)
                    const Text(
                      '1 / 3 explored',
                      style: TextStyle(
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              _LocationCard(
                title: 'Sleepy Forest',
                subtitle: _forestCompleted
                    ? 'Spud made it to the cabin! Play again?'
                    : 'Help Spud reach the forest cabin!',
                icon: Icons.forest_rounded,
                iconColor: const Color(0xFF4E8660),
                tileColor: const Color(0xFFE2EEE2),
                label: _loadingProgress
                    ? 'LOADING...'
                    : _forestCompleted
                        ? 'COMPLETED ✓'
                        : 'PLAY NOW',
                available: true,
                completed: _forestCompleted,
                onTap: _openSleepyForest,
              ),

              const SizedBox(height: 14),

              _LocationCard(
                title: 'Wobbly Beach',
                subtitle: 'A sunny adventure awaits.',
                icon: Icons.beach_access_rounded,
                iconColor: const Color(0xFFB48A50),
                tileColor: const Color(0xFFF7EBD6),
                label: 'COMING SOON',
                available: false,
                completed: false,
                onTap: () => _showComingSoon('Wobbly Beach'),
              ),

              const SizedBox(height: 14),

              _LocationCard(
                title: 'Potato Mountain',
                subtitle: 'A mountain-sized adventure for Spud.',
                icon: Icons.terrain_rounded,
                iconColor: const Color(0xFF8D8DA7),
                tileColor: const Color(0xFFE8E7F2),
                label: 'COMING SOON',
                available: false,
                completed: false,
                onTap: () => _showComingSoon('Potato Mountain'),
              ),

              const SizedBox(height: 28),

              const Center(
                child: Text(
                  'No pressure. No streaks. Just movement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color tileColor;
  final String label;
  final bool available;
  final bool completed;
  final VoidCallback onTap;

  const _LocationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.tileColor,
    required this.label,
    required this.available,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF3F6651);
    const darkText = Color(0xFF25332E);
    const secondaryText = Color(0xFF66736C);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: completed
                  ? const Color(0xFF9DC6A5)
                  : const Color(0xFFE4E9E2),
              width: completed ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 76,
                height: 86,
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  size: 43,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: TextStyle(
                        color: available ? primary : secondaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                completed
                    ? Icons.check_circle_rounded
                    : available
                        ? Icons.arrow_forward_ios_rounded
                        : Icons.lock_outline_rounded,
                color: available ? primary : secondaryText,
                size: completed ? 24 : 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
