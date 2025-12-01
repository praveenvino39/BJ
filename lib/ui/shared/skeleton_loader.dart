import 'dart:async';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SkeletonLoader extends StatefulWidget {
  final double height;
  final double width;
  Duration duration;
  SkeletonLoader(
      {super.key,
      required this.height,
      required this.width,
      this.duration = const Duration(milliseconds: 200)});

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> {
  double alpha = 1;
  Timer? timer;

  @override
  void initState() {
    timer = Timer.periodic(widget.duration, (timer) {
      if (!mounted) return;
      setState(() {
        alpha = alpha == 0.2 ? 1 : 0.2;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: alpha,
      duration: widget.duration,
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
