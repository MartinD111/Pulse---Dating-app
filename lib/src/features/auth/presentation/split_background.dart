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
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade900,
                      Colors.blue.shade600,
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.pink.shade900,
                      Colors.pink.shade600,
                    ],
                  ),
                ),
              ),
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
