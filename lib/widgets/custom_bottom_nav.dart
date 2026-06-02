import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A premium, organic custom bottom navigation bar with a curved cutout and a prominent floating action button in the center.
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 72 + bottomPadding,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Full-Width Navigation Bar Container ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 64 + bottomPadding,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primary, // Primary vivid green background
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Tab 0: HOME
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onTap(0),
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_rounded,
                              color: currentIndex == 0
                                  ? AppColors.white
                                  : AppColors.white.withValues(alpha: 0.6),
                              size: 24,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Beranda',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: currentIndex == 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: currentIndex == 0
                                    ? AppColors.white
                                    : AppColors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Middle spacer for FAB
                  const SizedBox(width: 80),

                  // Tab 2: RIWAYAT
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onTap(2),
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_rounded,
                              color: currentIndex == 2
                                  ? AppColors.white
                                  : AppColors.white.withValues(alpha: 0.6),
                              size: 24,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Riwayat',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: currentIndex == 2
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: currentIndex == 2
                                    ? AppColors.white
                                    : AppColors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Centered Prominent Floating Action Scan Button ──
          Positioned(
            top: -16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cardSurface, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(1),
                    customBorder: const CircleBorder(),
                    child: const Center(
                      child: Icon(
                        Icons.center_focus_strong_rounded, // Scan leaf focus icon
                        color: AppColors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
