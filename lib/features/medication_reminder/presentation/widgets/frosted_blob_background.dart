import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;

/// Reusable frosted/blurred colorful blob background used across pages.
class FrostedBlobBackground extends StatelessWidget {
  const FrostedBlobBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return IgnorePointer(
      child: Stack(
        children: [
          // Soft base gradient to blend with app surface
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    surface,
                    surface.withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),

          // Blurred blobs
          _blurredCircle(
            size: 340,
            color: const Color(0xFF34D399), // green 400
            sigma: 110,
            left: -70,
            top: -50,
          ),
          _blurredCircle(
            size: 380,
            color: const Color(0xFFF59E0B), // amber 500
            sigma: 110,
            right: -160,
            top: 310,
          ),
          _blurredCircle(
            size: 340,
            color: const Color(0xFF7C3AED), // accent purple
            sigma: 140,
            left: -120,
            bottom: -90,
          ),

          // Subtle global frost overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: SizedBox.expand(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.30),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Positioned _blurredCircle({
    required double size,
    required Color color,
    required double sigma,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withOpacity(0.50), color.withOpacity(0.18)],
            ),
          ),
        ),
      ),
    );
  }
}

