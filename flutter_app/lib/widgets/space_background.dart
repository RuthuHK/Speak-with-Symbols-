import 'dart:math';
import 'package:flutter/material.dart';

class SpaceBackground extends StatefulWidget {
  @override
  _SpaceBackgroundState createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Star> stars;

  @override
  void initState() {
    super.initState();
    final rand = Random();

    stars = List.generate(150, (_) {
      return Star(
        x: rand.nextDouble() * 800,
        y: rand.nextDouble() * 600,
        radius: rand.nextDouble() * 1.5 + 0.5,
        twinkleSpeed: 0.5 + rand.nextDouble() * 1.5,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          size: Size.infinite,
          painter: SpacePainter(
            stars: stars,
            time: _controller.value,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Star {
  double x;
  double y;
  double radius;
  double twinkleSpeed;

  Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.twinkleSpeed,
  });
}

class SpacePainter extends CustomPainter {
  final List<Star> stars;
  final double time;

  SpacePainter({required this.stars, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Space gradient background
    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.black, Colors.indigo.shade900],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Stars (twinkling)
    for (final star in stars) {
      final brightness = 0.5 +
          0.5 * sin(time * 2 * pi * star.twinkleSpeed + star.x + star.y);
      final starPaint = Paint()
        ..color = Colors.white.withOpacity(brightness.clamp(0.3, 1.0));
      canvas.drawCircle(Offset(star.x % w, star.y % h), star.radius, starPaint);
    }

    // Planet or moon
    final planetPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.deepPurple.shade900, Colors.transparent],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.2, h * 0.25), radius: 100));
    canvas.drawCircle(Offset(w * 0.2, h * 0.25), 100, planetPaint);

    // Nebula fog (optional atmospheric effect)
    final nebulaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.purple.withOpacity(0.1),
          Colors.blue.withOpacity(0.05),
          Colors.transparent
        ],
        radius: 1.0,
      ).createShader(Rect.fromCircle(center: Offset(w * 0.6, h * 0.7), radius: 250));
    canvas.drawCircle(Offset(w * 0.6, h * 0.7), 250, nebulaPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
