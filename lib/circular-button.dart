import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  final Color color;
  final double top;
  final double left;
  final double size;

  const CircularButton(
      {super.key,
      required this.color,
      required this.top,
      required this.left,
      required this.size});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top - size / 2,
      left: left - size / 2,
      child: Container(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        width: size,
        height: size,
      ),
    );
  }
}
