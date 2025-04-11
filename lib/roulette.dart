import 'package:flutter/material.dart';
import 'dart:math';

import 'package:roulette_wheel/const.dart';

class Roulette extends StatefulWidget {
  const Roulette({super.key});

  @override
  State<Roulette> createState() => _RouletteState();
}

class _RouletteState extends State<Roulette> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _ballAnimation; // New animation for the ball

  final Random _random = Random();
  double _currentAngle = 0;
  double _targetAngle = 0;
  double _ballPosition = 0; // Track ball position
  double _ballOffset = 0; // Ball offset from wheel

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    // Initialize with dummy animation
    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);
    _ballAnimation = Tween<double>(begin: 0, end: 0).animate(_controller);

    // Initial random position for the ball
    _ballPosition = _random.nextDouble() * 2 * pi;
  }

  void _spin() {
    final rotations = 5 + _random.nextInt(3);
    _targetAngle = _currentAngle + (2 * pi * rotations);

    // Random stopping position for the ball (different from wheel)
    final ballStopAngle = _random.nextDouble() * 2 * pi;

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

    // Create ball animation - ball moves faster initially and slows down sooner
    _ballAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: _ballPosition,
          // Ball spins faster than wheel initially
          end: _ballPosition - (2 * pi * (rotations + 2 + _random.nextInt(2))),
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 80,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: _ballPosition - (2 * pi * (rotations + 2 + _random.nextInt(2))),
          end: ballStopAngle,
        ).chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 20,
      ),
    ]).animate(_controller);

    // Ball bouncing effect during spin
    _ballOffset = 0.15;

    _controller
      ..reset()
      ..forward().whenComplete(() {
        _currentAngle = _targetAngle % (2 * pi);
        _ballPosition = ballStopAngle;
        _ballOffset = 0; // Ball settled in pocket
        print("Wheel stopped at: $_currentAngle, Ball at: $_ballPosition");
        setState(() {}); // Update UI after completion
      });

    setState(() {}); // Trigger rebuild
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animation.value,
              child: CustomPaint(
                size: const Size(400, 400),
                painter: _RoulettePainter(
                  ballPosition: _ballAnimation.value,
                  ballOffset: _ballOffset - (_controller.value * 0.1).abs().clamp(0.0, 0.1), // Create bouncing effect
                ),
              ),
            );
          },
        ),
        ElevatedButton(
          onPressed: _spin,
          child: const Text('SPIN'),
        ),
      ],
    );
  }
}

class _RoulettePainter extends CustomPainter {
  final double ballPosition;
  final double ballOffset;

  _RoulettePainter({
    this.ballPosition = 0.0,
    this.ballOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    List<String> numbers = americanRoulette;

    final anglePerSegment = (2 * pi) / numbers.length;

    // Draw roulette segments
    for (int i = 0; i < numbers.length; i++) {
      // Segment color logic
      if (int.parse(numbers[i]) == 0) {
        paint.color = Colors.green;
      } else {
        paint.color = i.isEven ? Colors.red : Colors.black;
      }

      // Draw segment
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * anglePerSegment,
        anglePerSegment,
        true,
        paint,
      );

      // Number styling
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

    // Draw detailed inner circle
    final innerRadius = radius * 0.6;

    // Draw wooden background
    paint.color = const Color(0xFF8B4513); // Wooden brown color
    canvas.drawCircle(center, innerRadius, paint);

    // Add wood grain texture (simple concentric circles)
    paint.color = const Color(0xFF6B3613); // Darker brown
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.8;

    for (int i = 1; i <= 10; i++) {
      canvas.drawCircle(center, innerRadius * (0.95 - i * 0.05), paint);
    }

    // Draw metallic cross structure
    paint.color = const Color(0xFFD3D3D3); // Light grey/silver
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 0;

    // Horizontal arm of cross
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: innerRadius * 1.4,
        height: innerRadius * 0.15,
      ),
      paint,
    );

    // Vertical arm of cross
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: innerRadius * 0.15,
        height: innerRadius * 1.4,
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
        width: innerRadius * 1.4,
        height: innerRadius * 0.15,
      ),
      paint,
    );

    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: innerRadius * 0.15,
        height: innerRadius * 1.4,
      ),
      paint,
    );

    // Draw center circle
    paint.color = const Color(0xFFD3D3D3); // Light grey/silver
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius * 0.15, paint);

    // Draw metallic nodes at the ends of cross
    final nodeRadius = innerRadius * 0.12;

    // Positions for the four nodes
    List<Offset> nodePositions = [
      Offset(center.dx + innerRadius * 0.7, center.dy), // Right
      Offset(center.dx - innerRadius * 0.7, center.dy), // Left
      Offset(center.dx, center.dy + innerRadius * 0.7), // Bottom
      Offset(center.dx, center.dy - innerRadius * 0.7), // Top
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
    canvas.drawCircle(center, innerRadius, paint);

    // Draw the ball
    final ballRadius = radius * 0.04; // Size of the ball
    final ballDistance = radius * (0.85 - ballOffset); // Distance from center
    final ballX = center.dx + ballDistance * cos(ballPosition);
    final ballY = center.dy + ballDistance * sin(ballPosition);

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
    return oldDelegate.ballPosition != ballPosition ||
        oldDelegate.ballOffset != ballOffset;
  }
}
