
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _forestBackground = Color(0xFFF8F7F3);
const _forestGreen = Color(0xFF3F6651);
const _forestDark = Color(0xFF25332E);
const _forestLight = Color(0xFFE4EDE5);

class SleepyForestScreen extends StatefulWidget {
  const SleepyForestScreen({super.key});

  @override
  State<SleepyForestScreen> createState() =>
      _SleepyForestScreenState();
}

class _SleepyForestScreenState extends State<SleepyForestScreen> {
  static const int stepGoal = 100;

  StreamSubscription<StepCount>? _subscription;

  int _steps = 0;
  int _savedSteps = 0;
  int? _baseline;
  int? _previousReading;

  bool _tracking = false;
  bool _paused = false;
  bool _loading = false;
  bool _completed = false;

  String _status = 'Spud is waiting for his walking buddy!';

  double get _progress =>
      (_steps / stepGoal).clamp(0.0, 1.0).toDouble();

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
        _savedSteps = 0;
      }

      _baseline = null;
      _previousReading = null;
      _tracking = true;
      _paused = false;
      _loading = false;
      _status = 'Adventure started! Keep your eyes on the path.';
    });

    try {
      _subscription = Pedometer.stepCountStream.listen(
        _onStep,
        onError: (Object error) {
          if (!mounted) return;

          setState(() {
            _tracking = false;
            _paused = true;
            _savedSteps = _steps;
            _status = 'Sensor error: $error';
          });
        },
        cancelOnError: true,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _tracking = false;
        _paused = true;
        _savedSteps = _steps;
        _status = 'Unable to start sensor: $error';
      });
    }
  }

  void _onStep(StepCount event) {
    if (!mounted || !_tracking || _completed) return;

    final reading = event.steps;
    _baseline ??= reading;

    if (_previousReading != null && reading < _previousReading!) {
      _savedSteps = _steps;
      _baseline = reading;
    }

    _previousReading = reading;

    final segmentSteps = math.max(0, reading - _baseline!);
    final total = math.min(stepGoal, _savedSteps + segmentSteps);

    setState(() {
      _steps = total;
      _status = total >= 75
          ? 'The cabin is right there! Spud can smell the snacks.'
          : total >= 40
              ? 'Halfway-ish! Spud says his legs are tiny.'
              : 'Every step brings Spud closer to the cabin!';
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
      _savedSteps = _steps;
      _status = 'Paused. Spud is pretending to be a rock.';
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
      _savedSteps = 0;
      _baseline = null;
      _previousReading = null;
      _loading = false;
      _status = 'Spud is waiting for his walking buddy!';
    });
  }

  Future<void> _finish() async {
    if (_completed) return;

    setState(() {
      _completed = true;
      _tracking = false;
      _status = 'Saving your adventure...';
    });

    await _subscription?.cancel();
    _subscription = null;

    bool saved = false;

    try {
      final preferences = await SharedPreferences.getInstance();
      saved = await preferences.setBool(
        'sleepy_forest_completed',
        true,
      );
    } catch (error) {
      saved = false;
    }

    if (!mounted) return;

    if (!saved) {
      setState(() {
        _status = 'Adventure complete, but progress could not be saved.';
      });
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ForestCompletionScreen(
          progressSaved: saved,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _forestBackground,
      appBar: AppBar(
        title: const Text(
          'Sleepy Forest',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _forestBackground,
        foregroundColor: _forestDark,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'A little walk in the woods',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _forestDark,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Help Spud find his cozy forest cabin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF66736C),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                height: 340,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCEBDC),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: AnimatedForestScene(
                  progress: _progress,
                  isWalking: _tracking,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Journey progress',
                    style: TextStyle(
                      color: _forestDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${(_progress * 100).round()}%',
                    style: const TextStyle(
                      color: _forestGreen,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _progress,
                minHeight: 13,
                borderRadius: BorderRadius.circular(20),
                backgroundColor: _forestLight,
                color: _forestGreen,
              ),
              const SizedBox(height: 12),
              Text(
                '$_steps / $stepGoal steps',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _forestGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _forestDark,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: (_loading || _completed)
                    ? null
                    : _tracking
                        ? _pause
                        : _start,
                icon: Icon(
                  _tracking
                      ? Icons.pause_rounded
                      : Icons.directions_walk_rounded,
                ),
                label: Text(
                  _completed
                      ? 'Completing...'
                      : _loading
                          ? 'Preparing...'
                          : _tracking
                              ? 'Pause Walking'
                              : _paused
                                  ? 'Resume Walking'
                                  : 'Start Walking',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _forestGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _completed ? null : _reset,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset Adventure'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _forestGreen,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Put your phone in your pocket and walk safely. '
                'Check your progress when you stop.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
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

class AnimatedForestScene extends StatefulWidget {
  final double progress;
  final bool isWalking;

  const AnimatedForestScene({
    super.key,
    required this.progress,
    required this.isWalking,
  });

  @override
  State<AnimatedForestScene> createState() =>
      _AnimatedForestSceneState();
}

class _AnimatedForestSceneState extends State<AnimatedForestScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    if (widget.isWalking) {
      _bounceController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedForestScene oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isWalking != oldWidget.isWalking) {
      if (widget.isWalking) {
        _bounceController.repeat(reverse: true);
      } else {
        _bounceController.stop();
        _bounceController.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        final point = ForestScenePainter.pathPoint(
          widget.progress,
          size,
        );

        return Stack(
          children: [
            CustomPaint(
              size: size,
              painter: ForestScenePainter(
                progress: widget.progress,
              ),
            ),
            AnimatedBuilder(
              animation: _bounceController,
              builder: (context, child) {
                final bounce = widget.isWalking
                    ? math.sin(
                            _bounceController.value * math.pi,
                          ) *
                          7
                    : 0.0;

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 550),
                  curve: Curves.easeInOut,
                  left: point.dx - 23,
                  top: point.dy - 53 - bounce,
                  child: child!,
                );
              },
              child: const _ForestSpud(),
            ),
            Positioned(
              left: 14,
              top: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  '🌲 LEVEL 1',
                  style: TextStyle(
                    color: _forestGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ForestScenePainter extends CustomPainter {
  final double progress;

  ForestScenePainter({required this.progress});

  static Offset pathPoint(double t, Size size) {
    final p = t.clamp(0.0, 1.0);
    final x = size.width * (0.13 + 0.72 * p);
    final y = size.height *
        (0.82 - 0.53 * p + 0.065 * math.sin(p * math.pi * 2));

    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFDCEBDC),
    );

    final hill = Path()
      ..moveTo(0, size.height * 0.40)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.17,
        size.width * 0.60,
        size.height * 0.38,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.23,
        size.width,
        size.height * 0.36,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      hill,
      Paint()..color = const Color(0xFFB7D4B6),
    );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height * 0.65,
        size.width,
        size.height * 0.35,
      ),
      Paint()..color = const Color(0xFF9FC49D),
    );

    _drawTree(canvas, size, 0.10, 0.25, 0.95);
    _drawTree(canvas, size, 0.30, 0.13, 0.75);
    _drawTree(canvas, size, 0.72, 0.15, 0.85);
    _drawTree(canvas, size, 0.91, 0.44, 0.85);
    _drawTree(canvas, size, 0.06, 0.68, 0.72);
    _drawTree(canvas, size, 0.45, 0.50, 0.68);

    final path = Path();

    for (int i = 0; i <= 70; i++) {
      final p = pathPoint(i / 70, size);

      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFF2E2BC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 31
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFD2B889)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    _drawFlower(canvas, size, 0.23, 0.70);
    _drawFlower(canvas, size, 0.55, 0.83);
    _drawFlower(canvas, size, 0.82, 0.72);

    _drawMushroom(canvas, size, 0.35, 0.92);
    _drawMushroom(canvas, size, 0.78, 0.56);

    _drawCabin(canvas, size);

    for (final t in [0.25, 0.50, 0.75]) {
      final point = pathPoint(t, size);

      canvas.drawCircle(
        point,
        5,
        Paint()
          ..color = t <= progress
              ? _forestGreen
              : Colors.white,
      );
    }
  }

  void _drawTree(
    Canvas canvas,
    Size size,
    double x,
    double y,
    double scale,
  ) {
    final center = Offset(
      size.width * x,
      size.height * y,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, 23 * scale),
          width: 10 * scale,
          height: 42 * scale,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF8C7257),
    );

    for (final layer in [0.0, 1.0, 2.0]) {
      final tree = Path()
        ..moveTo(
          center.dx,
          center.dy - (46 - layer * 15) * scale,
        )
        ..lineTo(
          center.dx - (27 - layer * 3) * scale,
          center.dy + (5 + layer * 13) * scale,
        )
        ..lineTo(
          center.dx + (27 - layer * 3) * scale,
          center.dy + (5 + layer * 13) * scale,
        )
        ..close();

      canvas.drawPath(
        tree,
        Paint()
          ..color = layer == 0
              ? const Color(0xFF4F8664)
              : layer == 1
                  ? const Color(0xFF609B73)
                  : const Color(0xFF3F7656),
      );
    }
  }

  void _drawFlower(
    Canvas canvas,
    Size size,
    double x,
    double y,
  ) {
    final center = Offset(
      size.width * x,
      size.height * y,
    );

    for (int i = 0; i < 5; i++) {
      final angle = i * math.pi * 2 / 5;

      canvas.drawCircle(
        center +
            Offset(
              math.cos(angle) * 5,
              math.sin(angle) * 5,
            ),
        4,
        Paint()..color = const Color(0xFFFFF6E3),
      );
    }

    canvas.drawCircle(
      center,
      3,
      Paint()..color = const Color(0xFFF1C56B),
    );
  }

  void _drawMushroom(
    Canvas canvas,
    Size size,
    double x,
    double y,
  ) {
    final center = Offset(
      size.width * x,
      size.height * y,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, 5),
          width: 9,
          height: 17,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFFFF6E3),
    );

    canvas.drawArc(
      Rect.fromCenter(
        center: center,
        width: 26,
        height: 22,
      ),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFFD98572),
    );
  }

  void _drawCabin(Canvas canvas, Size size) {
    final center = Offset(
      size.width * 0.85,
      size.height * 0.21,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          center.dx - 26,
          center.dy,
          52,
          42,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFB98B65),
    );

    final roof = Path()
      ..moveTo(center.dx - 34, center.dy + 3)
      ..lineTo(center.dx, center.dy - 26)
      ..lineTo(center.dx + 34, center.dy + 3)
      ..close();

    canvas.drawPath(
      roof,
      Paint()..color = const Color(0xFF785B4D),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          center.dx - 7,
          center.dy + 17,
          14,
          25,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF5B493E),
    );

    canvas.drawRect(
      Rect.fromLTWH(
        center.dx + 11,
        center.dy + 9,
        11,
        11,
      ),
      Paint()
        ..color = progress >= 0.75
            ? const Color(0xFFFFD87A)
            : const Color(0xFFD7E6D2),
    );
  }

  @override
  bool shouldRepaint(covariant ForestScenePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ForestSpud extends StatelessWidget {
  const _ForestSpud();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 56,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          const Positioned(
            top: 0,
            child: Icon(
              Icons.eco_rounded,
              size: 25,
              color: Color(0xFF4D9361),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 43,
              height: 42,
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
                  color: _forestDark,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ForestCompletionScreen extends StatelessWidget {
  final bool progressSaved;

  const ForestCompletionScreen({
    super.key,
    required this.progressSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _forestBackground,
      appBar: AppBar(
        title: const Text('Adventure Complete'),
        backgroundColor: _forestBackground,
        foregroundColor: _forestDark,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    color: _forestLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cottage_rounded,
                    color: _forestGreen,
                    size: 85,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Spud made it! 🥔🎉',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _forestDark,
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '"I walked 100 steps for a potato-sized house. '
                  'Worth it."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.5,
                    color: _forestDark,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  progressSaved
                      ? 'Sleepy Forest completed! Progress saved.'
                      : 'Adventure complete! Progress could not be saved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: progressSaved
                        ? _forestGreen
                        : Colors.deepOrange,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _forestGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Text(
                      'Back to Adventure Map',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
