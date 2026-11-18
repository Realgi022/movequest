
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class SleepyForestScreen extends StatefulWidget {
  const SleepyForestScreen({super.key});

  @override
  State<SleepyForestScreen> createState() => _SleepyForestScreenState();
}

class _SleepyForestScreenState extends State<SleepyForestScreen> {
  static const int stepGoal = 100;

  static const Color background = Color(0xFFF8F7F3);
  static const Color primary = Color(0xFF3F6651);
  static const Color darkText = Color(0xFF25332E);
  static const Color lightGreen = Color(0xFFE4EDE5);

  StreamSubscription<StepCount>? _subscription;

  int _steps = 0;
  int? _lastReading;
  int? _baseline;
  int _pendingResumeSteps = 0;

  bool _tracking = false;
  bool _loading = false;
  bool _paused = false;
  bool _completed = false;

  String _status = 'Ready for a little adventure?';

  double get _progress => (_steps / stepGoal).clamp(0.0, 1.0);

  Future<void> _start() async {
    if (_tracking || _loading || _completed) return;

    setState(() {
      _loading = true;
      _status = 'Checking activity permission...';
    });

    final permission = await Permission.activityRecognition.request();

    if (!mounted) return;

    if (!permission.isGranted) {
      setState(() {
        _loading = false;
        _status = permission.isPermanentlyDenied
            ? 'Enable Physical Activity permission in Settings.'
            : 'Physical Activity permission is required.';
      });
      return;
    }

    await _subscription?.cancel();
    _subscription = null;

    if (!mounted) return;

    setState(() {
      if (!_paused) {
        _steps = 0;
        _pendingResumeSteps = 0;
      }
      _baseline = null;
      _lastReading = null;
      _tracking = true;
      _paused = false;
      _loading = false;
      _status = 'Walk safely! Spud is on the move.';
    });

    try {
      _subscription = Pedometer.stepCountStream.listen(
        _onStep,
        onError: (Object error) {
          if (!mounted) return;
          setState(() {
            _tracking = false;
            _status = 'Sensor error: $error';
          });
        },
        cancelOnError: true,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _tracking = false;
        _status = 'Could not start sensor: $error';
      });
    }
  }

  void _onStep(StepCount event) {
    if (!mounted || !_tracking || _completed) return;

    final reading = event.steps;

    // First event establishes the starting point for this segment.
    _baseline ??= reading;

    // Handle a sensor reset after a device reboot.
    if (reading < _baseline!) {
      _baseline = reading;
    }

    final segmentSteps = (reading - _baseline!).clamp(0, stepGoal);
    final total = (_pendingResumeSteps + segmentSteps).clamp(0, stepGoal);

    setState(() {
      _lastReading = reading;
      _steps = total;
      _status = 'Keep going! The cabin is getting closer.';
    });

    if (total >= stepGoal) {
      _finish();
    }
  }

  Future<void> _pause() async {
    if (!_tracking) return;

    setState(() {
      _tracking = false;
      _paused = true;
      _pendingResumeSteps = _steps;
      _status = 'Paused. Spud is taking a potato break.';
    });

    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _reset() async {
    setState(() {
      _tracking = false;
      _paused = false;
      _completed = false;
    });

    await _subscription?.cancel();
    _subscription = null;

    if (!mounted) return;

    setState(() {
      _steps = 0;
      _lastReading = null;
      _baseline = null;
      _pendingResumeSteps = 0;
      _loading = false;
      _status = 'Ready for a little adventure?';
    });
  }

  void _finish() {
    if (_completed) return;

    _completed = true;
    _tracking = false;
    _subscription?.cancel();
    _subscription = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ForestCompletionScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Sleepy Forest'),
        backgroundColor: background,
        foregroundColor: darkText,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Help Spud reach the cabin!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your real steps move Spud along the trail.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Forest gameplay area
              Container(
                height: 260,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final trackWidth = constraints.maxWidth - 90;
                    final spudX = 20 + trackWidth * _progress;

                    return Stack(
                      children: [
                        const Positioned(
                          top: 20,
                          left: 18,
                          child: Icon(
                            Icons.forest_rounded,
                            size: 75,
                            color: Color(0xFF81AC86),
                          ),
                        ),
                        const Positioned(
                          top: 20,
                          right: 18,
                          child: Icon(
                            Icons.park_rounded,
                            size: 65,
                            color: Color(0xFF81AC86),
                          ),
                        ),
                        const Positioned(
                          top: 88,
                          right: 30,
                          child: Icon(
                            Icons.cottage_rounded,
                            size: 58,
                            color: primary,
                          ),
                        ),
                        Positioned(
                          left: 25,
                          right: 25,
                          bottom: 50,
                          child: Container(
                            height: 13,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6C6A6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeInOut,
                          left: spudX,
                          bottom: 46,
                          child: const _LittleSpud(),
                        ),
                        const Positioned(
                          bottom: 12,
                          left: 22,
                          child: Text(
                            'START',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: 12,
                          right: 22,
                          child: Text(
                            'CABIN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              Text(
                '$_steps / $stepGoal steps',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              const SizedBox(height: 16),

              LinearProgressIndicator(
                value: _progress,
                minHeight: 14,
                borderRadius: BorderRadius.circular(12),
                backgroundColor: lightGreen,
                color: primary,
              ),

              const SizedBox(height: 22),

              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: darkText,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _loading
                    ? null
                    : _tracking
                        ? _pause
                        : _start,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _loading
                      ? 'Preparing...'
                      : _tracking
                          ? 'Pause Walking'
                          : _paused
                              ? 'Resume Walking'
                              : 'Start Walking',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: _reset,
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Reset Session'),
              ),

              const SizedBox(height: 18),

              const Text(
                'Put your phone in your pocket and walk safely. '
                'You do not need to watch the screen.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LittleSpud extends StatelessWidget {
  const _LittleSpud();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 62,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          const Positioned(
            top: 0,
            child: Icon(
              Icons.eco_rounded,
              size: 25,
              color: Color(0xFF77A889),
            ),
          ),
          Container(
            width: 44,
            height: 43,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF3C879),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(
                color: const Color(0xFFB98A46),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.sentiment_satisfied_alt_rounded,
                color: Color(0xFF25332E),
                size: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ForestCompletionScreen extends StatelessWidget {
  const ForestCompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF8F7F3);
    const primary = Color(0xFF3F6651);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Adventure Complete'),
        backgroundColor: background,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.celebration_rounded,
                  size: 90,
                  color: Color(0xFFF3C879),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Spud made it! 🥔',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'I walked 100 steps for a potato-sized house. '
                  'Worth it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'You completed Sleepy Forest!',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 34),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: const Text('Back to Adventure Map'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
