// lib/screens/falling_icon.dart
import 'package:flutter/material.dart';

class FallingIcon extends StatefulWidget {
  final String imagePath;
  final double startX;

  const FallingIcon({
    Key? key,
    required this.imagePath,
    required this.startX,
  }) : super(key: key);

  @override
  _FallingIconState createState() => _FallingIconState();
}

class _FallingIconState extends State<FallingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _animation = Tween<double>(begin: 0, end: 600).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: _animation.value,
          left: widget.startX,
          child: Image.asset(
            widget.imagePath,
            width: 64,
            height: 64,
          ),
        );
      },
    );
  }
}