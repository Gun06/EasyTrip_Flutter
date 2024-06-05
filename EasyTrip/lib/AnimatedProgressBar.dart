import 'package:flutter/material.dart';

class AnimatedProgressBar extends StatelessWidget {
  final double progress;

  const AnimatedProgressBar({Key? key, required this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: Duration(seconds: 1),
      builder: (context, value, child) {
        return LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey[200],
          color: Colors.blue,
        );
      },
    );
  }
}
