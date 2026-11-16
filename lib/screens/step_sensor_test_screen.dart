
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class StepSensorTestScreen extends StatefulWidget {
  const StepSensorTestScreen({super.key});

  @override
  State<StepSensorTestScreen> createState() =>
      _StepSensorTestScreenState();
}

class _StepSensorTestScreenState extends State<StepSensorTestScreen> {
  static const int stepGoal = 500;

  StreamSubscription<StepCount>? _stepSubscription;

  int _steps = 0;
  int? _startingSteps;
  int? _lastSensorReading;

  bool _isTracking = false;
  bool _isLoading = false;

  String _status = 'Ready to start walking!';

  double get _progress =>
      (_steps / stepGoal).clamp(0.0, 1.0).toDouble();

  Future<void> _startWalking() async {
    if (_isTracking || _isLoading) return;

    setState(() {
      _isLoading = true;
      _status = 'Checking permissions...';
    });

    final permission =
        await Permission.activityRecognition.request();

    if (!mounted) return;

    if (!permission.isGranted) {
      setState(() {
        _isLoading = false;
        _status = permission.isPermanentlyDenied
            ? 'Enable Physical Activity permission in Settings.'
            : 'Physical Activity permission is required.';
      });
      return;
    }

    await _stepSubscription?.cancel();
    _stepSubscription = null;

    if (!mounted) return;

    setState(() {
      _steps = 0;
      _startingSteps = null;
      _isTracking = true;
      _isLoading = false;
      _status = 'Waiting for sensor data...';
    });

    try {
      _stepSubscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: (Object error) {
          if (!mounted) return;

          setState(() {
            _isTracking = false;
            _status = 'Sensor error: $error';
          });
        },
        cancelOnError: true,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isTracking = false;
        _status = 'Unable to start sensor: $error';
      });
    }
  }

  void _onStepCount(StepCount event) {
    if (!mounted || !_isTracking) return;

    final currentSteps = event.steps;

    // Android reports cumulative steps since device reboot.
    // Save the first reading as the session baseline.
    _startingSteps ??= currentSteps;

    // Handle the sensor counter resetting.
    if (currentSteps < _startingSteps!) {
      _startingSteps = currentSteps;
    }

    final sessionSteps = currentSteps - _startingSteps!;

    setState(() {
      _lastSensorReading = currentSteps;
      _steps = sessionSteps;

      if (_steps >= stepGoal) {
        _status = '🎉 Goal completed! Spud is proud of you!';
      } else {
        _status = '🥔 Keep walking! Spud needs your help!';
      }
    });
  }

  Future<void> _resetSession() async {
    await _stepSubscription?.cancel();
    _stepSubscription = null;

    if (!mounted) return;

    setState(() {
      _steps = 0;
      _startingSteps = null;
      _lastSensorReading = null;
      _isTracking = false;
      _isLoading = false;
      _status = 'Session reset. Ready to walk again!';
    });
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF8F7F3);
    const primaryGreen = Color(0xFF3F6651);
    const darkText = Color(0xFF25332E);
    const lightGreen = Color(0xFFE4EDE5);

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        title: const Text('Walking Prototype'),
        backgroundColor: background,
        foregroundColor: darkText,
        elevation: 0,
      ),

      // Scrollable layout prevents bottom overflow
      // on smaller Android screens.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              const Icon(
                Icons.directions_walk_rounded,
                size: 80,
                color: primaryGreen,
              ),

              const SizedBox(height: 20),

              const Text(
                'Help Spud Move!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Every step brings Spud closer to the goal.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 45),

              Text(
                '$_steps',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),

              const Text(
                'STEPS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  letterSpacing: 3,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 28),

              LinearProgressIndicator(
                value: _progress,
                minHeight: 14,
                borderRadius: BorderRadius.circular(12),
                backgroundColor: lightGreen,
                color: primaryGreen,
              ),

              const SizedBox(height: 12),

              Text(
                '$_steps / $stepGoal steps',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: darkText,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 30),

              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: darkText,
                  fontSize: 15,
                ),
              ),

              // Fixed spacing instead of Spacer().
              // Spacer cannot be used inside an
              // unbounded scrollable Column.
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: (_isTracking || _isLoading)
                    ? null
                    : _startWalking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _isLoading
                      ? 'Preparing...'
                      : _isTracking
                          ? 'Tracking Steps...'
                          : 'Start Walking',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: _resetSession,
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryGreen,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Reset Session'),
              ),

              const SizedBox(height: 16),

              Text(
                'Sensor total: ${_lastSensorReading ?? "Waiting"}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
