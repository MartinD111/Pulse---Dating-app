import 'package:flutter/material.dart';

class SplitBackground extends StatelessWidget {
  final Widget child;

  const SplitBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(color: Colors.blue.shade900),
            ),
            Expanded(
              child: Container(color: Colors.pink.shade900),
            ),
          ],
        ),
        // Glass overlay to blend it a bit
        Container(
          color: Colors.black.withValues(alpha: 0.3),
        ),
        SafeArea(child: child),
      ],
    );
  }
}
