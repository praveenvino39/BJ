import 'package:flutter/material.dart';

class NetworkDot extends StatelessWidget {
  final Color color;
  final double radius;
  const NetworkDot({Key? key, required this.color, this.radius = 7.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(radius)),
    );
  }
}
