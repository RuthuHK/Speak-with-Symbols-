import 'dart:math';
import 'package:flutter/material.dart';

class JungleBackground extends StatefulWidget {
  @override
  _JungleBackgroundState createState() => _JungleBackgroundState();
}

class _JungleBackgroundState extends State<JungleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Cloud> clouds;

  @override
  void initState() {
    super.initState();
    final rand = Random();
    clouds = List.generate(3, (_) {
      return Cloud(
        x: rand.nextDouble() * 400,
        y: 30 + rand.nextDouble() * 50,
        speed: 5 + rand.nextDouble() * 10,
      );
    });

    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 60))
          ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          size: Size.infinite,
          painter: JunglePainter(
            clouds: clouds,
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

class Cloud {
  double x;
  double y;
  double speed;

  Cloud({required this.x, required this.y, required this.speed});
}

class JunglePainter extends CustomPainter {
  final List<Cloud> clouds;
  final double time;

  JunglePainter({required this.clouds, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final skyPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.lightBlue.shade100, Colors.lightGreen.shade200],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.yellowAccent.withOpacity(0.3 + 0.1 * sin(time * 2 * pi)),
          Colors.transparent
        ],
      ).createShader(Rect.fromCircle(center: Offset(80, 80), radius: 100));
    canvas.drawCircle(Offset(80, 80), 100, sunPaint);

    final cloudPaint = Paint()..color = Colors.white.withOpacity(0.8);
    for (final cloud in clouds) {
      double dx = (cloud.x + time * cloud.speed * 100) % w;
      canvas.drawOval(Rect.fromLTWH(dx, cloud.y, 60, 25), cloudPaint);
      canvas.drawOval(Rect.fromLTWH(dx + 20, cloud.y - 10, 50, 30), cloudPaint);
      canvas.drawOval(Rect.fromLTWH(dx + 40, cloud.y, 50, 25), cloudPaint);
    }

    drawHillLayer(canvas, w, h, 340, 30, Colors.green.shade800, time, 0.2);
    drawHillLayer(canvas, w, h, 370, 40, Colors.green.shade700, time, 0.1);
    drawHillLayer(canvas, w, h, 400, 50, Colors.green.shade900, time, 0.05);

    final bushPaint = Paint()..color = Colors.green.shade900;
    for (double x = 0; x < w; x += 40) {
      canvas.drawOval(Rect.fromLTWH(x, h - 40, 50, 30), bushPaint);
    }

    final groundPaint = Paint()..color = Colors.green.shade800;
    canvas.drawRect(Rect.fromLTWH(0, h - 30, w, 30), groundPaint);
  }

  void drawHillLayer(Canvas canvas, double w, double h, double baseY,
      double waveHeight, Color color, double time, double speed) {
    final path = Path()..moveTo(0, h);
    for (double x = 0; x <= w; x++) {
      double y = baseY +
          sin((x / w * 2 * pi) + time * 2 * pi * speed) * waveHeight;
      path.lineTo(x, y);
    }
    path.lineTo(w, h);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
// // import 'dart:math';
// // import 'package:flutter/material.dart';

// // class JungleBackground extends StatefulWidget {
// //   @override
// //   _JungleBackgroundState createState() => _JungleBackgroundState();
// // }

// // class _JungleBackgroundState extends State<JungleBackground>
// //     with SingleTickerProviderStateMixin {
// //   late AnimationController _controller;
// //   late List<Cloud> clouds;

// //   @override
// //   void initState() {
// //     super.initState();
// //     final rand = Random();
// //     clouds = List.generate(3, (_) {
// //       return Cloud(
// //         x: rand.nextDouble() * 400,
// //         y: 30 + rand.nextDouble() * 50,
// //         speed: 5 + rand.nextDouble() * 10,
// //       );
// //     });

// //     _controller =
// //         AnimationController(vsync: this, duration: Duration(seconds: 60))
// //           ..repeat();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return AnimatedBuilder(
// //       animation: _controller,
// //       builder: (_, __) {
// //         return CustomPaint(
// //           size: Size.infinite,
// //           painter: JunglePainter(
// //             clouds: clouds,
// //             time: _controller.value,
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _controller.dispose();
// //     super.dispose();
// //   }
// // }

// // class Cloud {
// //   double x;
// //   double y;
// //   double speed;

// //   Cloud({required this.x, required this.y, required this.speed});
// // }

// // class JunglePainter extends CustomPainter {
// //   final List<Cloud> clouds;
// //   final double time;

// //   JunglePainter({required this.clouds, required this.time});

// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final w = size.width;
// //     final h = size.height;

// //     // Sky without green
// //     final skyPaint = Paint()
// //       ..shader = LinearGradient(
// //         colors: [Colors.lightBlue.shade100, Colors.blue.shade300],
// //         begin: Alignment.topCenter,
// //         end: Alignment.bottomCenter,
// //       ).createShader(Rect.fromLTWH(0, 0, w, h));
// //     canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

// //     // Sun
// //     final sunPaint = Paint()
// //       ..shader = RadialGradient(
// //         colors: [
// //           Colors.yellowAccent.withOpacity(0.3 + 0.1 * sin(time * 2 * pi)),
// //           Colors.transparent
// //         ],
// //       ).createShader(Rect.fromCircle(center: Offset(80, 80), radius: 100));
// //     canvas.drawCircle(Offset(80, 80), 100, sunPaint);

// //     // Clouds
// //     final cloudPaint = Paint()..color = Colors.white.withOpacity(0.8);
// //     for (final cloud in clouds) {
// //       double dx = (cloud.x + time * cloud.speed * 100) % w;
// //       canvas.drawOval(Rect.fromLTWH(dx, cloud.y, 60, 25), cloudPaint);
// //       canvas.drawOval(Rect.fromLTWH(dx + 20, cloud.y - 10, 50, 30), cloudPaint);
// //       canvas.drawOval(Rect.fromLTWH(dx + 40, cloud.y, 50, 25), cloudPaint);
// //     }

// //     // All green hill layers removed
// //   }

// //   @override
// //   bool shouldRepaint(CustomPainter oldDelegate) => true;
// // }

// // import 'dart:math';
// // import 'package:flutter/material.dart';

// // class JungleBackground extends StatefulWidget {
// //   @override
// //   _JungleBackgroundState createState() => _JungleBackgroundState();
// // }

// // class _JungleBackgroundState extends State<JungleBackground>
// //     with SingleTickerProviderStateMixin {
// //   late AnimationController _controller;
// //   late List<Cloud> clouds;

// //   @override
// //   void initState() {
// //     super.initState();
// //     final rand = Random();
// //     clouds = List.generate(3, (_) {
// //       return Cloud(
// //         x: rand.nextDouble() * 400,
// //         y: 30 + rand.nextDouble() * 50,
// //         speed: 5 + rand.nextDouble() * 10,
// //       );
// //     });

// //     _controller =
// //         AnimationController(vsync: this, duration: Duration(seconds: 60))
// //           ..repeat();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return AnimatedBuilder(
// //       animation: _controller,
// //       builder: (_, __) {
// //         return CustomPaint(
// //           size: Size.infinite,
// //           painter: JunglePainter(
// //             clouds: clouds,
// //             time: _controller.value,
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _controller.dispose();
// //     super.dispose();
// //   }
// // }

// // class Cloud {
// //   double x;
// //   double y;
// //   double speed;

// //   Cloud({required this.x, required this.y, required this.speed});
// // }

// // class JunglePainter extends CustomPainter {
// //   final List<Cloud> clouds;
// //   final double time;

// //   JunglePainter({required this.clouds, required this.time});

// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final w = size.width;
// //     final h = size.height;

// //     // Sky (blue gradient only)
// //     final skyPaint = Paint()
// //       ..shader = LinearGradient(
// //         colors: [Colors.lightBlue.shade100, Colors.blue.shade300],
// //         begin: Alignment.topCenter,
// //         end: Alignment.bottomCenter,
// //       ).createShader(Rect.fromLTWH(0, 0, w, h));
// //     canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

// //     // Sun
// //     final sunPaint = Paint()
// //       ..shader = RadialGradient(
// //         colors: [
// //           Colors.yellowAccent.withOpacity(0.3 + 0.1 * sin(time * 2 * pi)),
// //           Colors.transparent
// //         ],
// //       ).createShader(Rect.fromCircle(center: Offset(80, 80), radius: 100));
// //     canvas.drawCircle(Offset(80, 80), 100, sunPaint);

// //     // Translucent clouds
// //     final cloudPaint = Paint()..color = Colors.white.withOpacity(0.5);
// //     for (final cloud in clouds) {
// //       double dx = (cloud.x + time * cloud.speed * 100) % w;
// //       canvas.drawOval(Rect.fromLTWH(dx, cloud.y, 60, 25), cloudPaint);
// //       canvas.drawOval(Rect.fromLTWH(dx + 20, cloud.y - 10, 50, 30), cloudPaint);
// //       canvas.drawOval(Rect.fromLTWH(dx + 40, cloud.y, 50, 25), cloudPaint);
// //     }

// //     // No green hills, bushes, or ground
// //   }

// //   @override
// //   bool shouldRepaint(CustomPainter oldDelegate) => true;
// // }
