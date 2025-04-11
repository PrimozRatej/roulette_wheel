import 'package:flutter/material.dart';
import 'dart:math';

import 'package:roulette_wheel/const.dart';

class RouletteWheel extends StatefulWidget {
  final Function(int) onRoundEnd;

  const RouletteWheel({super.key, required this.onRoundEnd});

  @override
  State<RouletteWheel> createState() => RouletteWheelState();
}

class RouletteWheelState extends State<RouletteWheel> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _ballAnimation;

  late double rouletteSize = MediaQuery.of(context).size.height * 0.9;

  final Random _random = Random();
  double _currentAngle = 0;
  double _targetAngle = 0;
  double _ballPosition = 0;
  double _ballOffset = 0;
  bool _ballInPocket = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);
    _ballAnimation = Tween<double>(begin: 0, end: 0).animate(_controller);

    // Initial random position for the ball
    _ballPosition = _random.nextDouble() * 2 * pi;
  }

  void spin() {
    final rotations = 5 + _random.nextInt(3);
    _targetAngle = _currentAngle + (2 * pi * rotations);

    // Get a random segment to land on
    final selectedSegment = _random.nextInt(americanRoulette.length);
    final segmentAngle = (2 * pi / americanRoulette.length) * selectedSegment;

    setState(() {
      _ballInPocket = false;
    });

    // Create wheel animation
    _animation = Tween<double>(
      begin: _currentAngle,
      end: _targetAngle,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.decelerate,
      ),
    );

    // Create ball animation - three phases:
    // 1. Fast movement opposite to wheel
    // 2. Slowing down
    // 3. Landing in pocket
    _ballAnimation = TweenSequence<double>([
      // Phase 1: Fast spinning (opposite direction, more rotations)
      TweenSequenceItem(
        tween: Tween<double>(
          begin: _ballPosition,
          end: _ballPosition - (2 * pi * (rotations + 3)),
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      // Phase 2: Slowing down
      TweenSequenceItem(
        tween: Tween<double>(
          begin: _ballPosition - (2 * pi * (rotations + 3)),
          end: _ballPosition - (2 * pi * (rotations + 3.5)),
        ).chain(CurveTween(curve: Curves.decelerate)),
        weight: 30,
      ),
      // Phase 3: Final adjustment to land in pocket
      TweenSequenceItem(
        tween: Tween<double>(
          begin: _ballPosition - (2 * pi * (rotations + 3.5)),
          end: segmentAngle, // Align with a specific pocket
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 10,
      ),
    ]).animate(_controller);

    // Ball bouncing effect during spin (higher in beginning)
    _ballOffset = 0.5;

    _controller
      ..reset()
      ..forward().whenComplete(() {
        _currentAngle = _targetAngle % (2 * pi);
        _ballPosition = segmentAngle;

        // Ball is now in a pocket
        setState(() {
          _ballInPocket = true;
          _ballOffset = 0; // No more bouncing
        });
        widget.onRoundEnd(int.parse(americanRoulette[selectedSegment]));
        print("Winner: ${americanRoulette[selectedSegment]}");
      });

    setState(() {}); // Trigger rebuild
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: CustomPaint(
            size: Size(rouletteSize, rouletteSize),
            painter: _RoulettePainter(
              ballPosition: _ballAnimation.value,
              ballOffset: _ballOffset * (1 - _controller.value), // Reducing bounce over time
              ballInPocket: _ballInPocket,
            ),
          ),
        );
      },
    );
  }
}

class _RoulettePainter extends CustomPainter {
  final double ballPosition;
  final double ballOffset;
  final bool ballInPocket;

  _RoulettePainter({
    this.ballPosition = 0.0,
    this.ballOffset = 0.0,
    this.ballInPocket = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerWoodenRadius = radius * 0.6; // Wooden center radius
    final pocketRadius = radius * 0.77; // Where numbers end (inner circle)
    final ballTrackRadius = radius * 0.82; // Where ball rolls

    // Start with white background for the wheel
    paint.color = Colors.white;
    canvas.drawCircle(center, radius, paint);

    List<String> numbers = americanRoulette;
    final anglePerSegment = (2 * pi) / numbers.length;

    // Draw roulette segments (pockets) - STEP 1
    for (int i = 0; i < numbers.length; i++) {
      // Segment color logic
      if (numbers[i] == "0" || numbers[i] == "00") {
        paint.color = Colors.green;
      } else {
        paint.color = i % 2 == 0 ? Colors.red : Colors.black;
      }

      // Draw segment
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * anglePerSegment,
        anglePerSegment,
        true,
        paint,
      );
    }

    // Draw white pocket dividers - STEP 2
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.0;

    for (int i = 0; i < numbers.length; i++) {
      final startAngle = i * anglePerSegment;
      final lineStartX = center.dx + pocketRadius * cos(startAngle);
      final lineStartY = center.dy + pocketRadius * sin(startAngle);
      final lineEndX = center.dx + radius * cos(startAngle);
      final lineEndY = center.dy + radius * sin(startAngle);

      canvas.drawLine(
        Offset(lineStartX, lineStartY),
        Offset(lineEndX, lineEndY),
        paint,
      );
    }

    // Draw numbers - STEP 3
    for (int i = 0; i < numbers.length; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: numbers[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Calculate angle and position
      final angle = (i * anglePerSegment) + (anglePerSegment / 2);
      final textRadius = radius - 20; // Move numbers slightly inward
      final x = center.dx + textRadius * cos(angle);
      final y = center.dy + textRadius * sin(angle);

      // Rotate text to face outward
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + pi / 2); // Add rotation for outward-facing text
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2), // Center text
      );
      canvas.restore();
    }

    // Draw black dividing line between numbers and wooden center
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3.0;
    canvas.drawCircle(center, pocketRadius, paint);

    // Draw detailed inner circle (wooden background)
    paint.color = const Color(0xFF8B4513); // Wooden brown color
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, innerWoodenRadius, paint);

    // Add wood grain texture (concentric circles)
    paint.color = const Color(0xFF6B3613); // Darker brown
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.8;

    for (int i = 1; i <= 10; i++) {
      canvas.drawCircle(center, innerWoodenRadius * (0.95 - i * 0.05), paint);
    }

    // Draw metallic cross structure
    paint.color = const Color(0xFFD3D3D3); // Light grey/silver
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 0;

    // Horizontal arm of cross
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: innerWoodenRadius * 1.4,
        height: innerWoodenRadius * 0.15,
      ),
      paint,
    );

    // Vertical arm of cross
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: innerWoodenRadius * 0.15,
        height: innerWoodenRadius * 1.4,
      ),
      paint,
    );

    // Add metallic border around arms
    paint.color = const Color(0xFF808080); // Grey
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.0;

    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: innerWoodenRadius * 1.4,
        height: innerWoodenRadius * 0.15,
      ),
      paint,
    );

    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: innerWoodenRadius * 0.15,
        height: innerWoodenRadius * 1.4,
      ),
      paint,
    );

    // Draw center circle
    paint.color = const Color(0xFFD3D3D3); // Light grey/silver
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, innerWoodenRadius * 0.15, paint);

    // Draw metallic nodes at the ends of cross
    final nodeRadius = innerWoodenRadius * 0.12;

    // Positions for the four nodes
    List<Offset> nodePositions = [
      Offset(center.dx + innerWoodenRadius * 0.7, center.dy), // Right
      Offset(center.dx - innerWoodenRadius * 0.7, center.dy), // Left
      Offset(center.dx, center.dy + innerWoodenRadius * 0.7), // Bottom
      Offset(center.dx, center.dy - innerWoodenRadius * 0.7), // Top
    ];

    // Draw the nodes
    for (var nodeCenter in nodePositions) {
      paint.color = const Color(0xFFD3D3D3); // Light grey/silver
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(nodeCenter, nodeRadius, paint);

      // Add a highlight to make it look 3D
      paint.color = const Color(0xFFEEEEEE); // Lighter grey for highlight
      canvas.drawCircle(
        Offset(nodeCenter.dx - 2, nodeCenter.dy - 2),
        nodeRadius * 0.6,
        paint,
      );
    }

    // Add a thin border around the entire inner circle
    paint.color = const Color(0xFF444444); // Dark grey
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    canvas.drawCircle(center, innerWoodenRadius, paint);

    // Draw the ball
    final ballRadius = radius * 0.04; // Size of the ball
    double ballDistance;
    double ballX, ballY;

    if (ballInPocket) {
      // Calculate the pocket position - aligning with a specific number
      final segmentIndex = (ballPosition / anglePerSegment).round() % numbers.length;
      final pocketAngle = (segmentIndex * anglePerSegment) + (anglePerSegment / 2);

      // Position the ball in the middle of the pocket
      ballDistance = pocketRadius * 0.90; // Slightly inside the pocket circle
      ballX = center.dx + ballDistance * cos(pocketAngle);
      ballY = center.dy + ballDistance * sin(pocketAngle);
    } else {
      // Ball is still rolling on the track
      ballDistance = ballTrackRadius - (ballOffset * radius * 0.1); // Ball track with offset
      ballX = center.dx + ballDistance * cos(ballPosition);
      ballY = center.dy + ballDistance * sin(ballPosition);
    }

    // Ball shadow
    paint.color = Colors.black54;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(ballX + 1, ballY + 1),
      ballRadius,
      paint,
    );

    // Ball body
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(ballX, ballY),
      ballRadius,
      paint,
    );

    // Ball highlight
    paint.color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(
      Offset(ballX - ballRadius * 0.3, ballY - ballRadius * 0.3),
      ballRadius * 0.4,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RoulettePainter oldDelegate) {
    return oldDelegate.ballPosition != ballPosition || oldDelegate.ballOffset != ballOffset || oldDelegate.ballInPocket != ballInPocket;
  }
}
