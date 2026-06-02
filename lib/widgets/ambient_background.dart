import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Renders a premium nature-light ambient background with a soft organic green glow diffusing from the corners.
class AmbientBackground extends StatelessWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.background,
      ),
      child: Stack(
        children: [
          // ── Soft Organic Upper-Left Radial Green Glow ──
          Positioned(
            top: -150,
            left: -150,
            width: 400,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.accentGreen.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Soft Lower-Right Green Glow ──
          Positioned(
            bottom: -200,
            right: -100,
            width: 450,
            height: 450,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentGreen.withValues(alpha: 0.08),
                    AppColors.lightGreen.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Content Child ──
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
