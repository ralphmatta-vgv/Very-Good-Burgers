import 'package:flutter/material.dart';

import '../utils/theme.dart';

class PromoCard extends StatelessWidget {
  const PromoCard({
    super.key,
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.onTap,
    this.tag = 'LIMITED TIME',
  });

  final String tag;
  final String title;
  final String description;
  final String ctaLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Multi-stop gradient background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.95),
                      AppColors.primaryDark,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Subtle diagonal highlight for depth
            Positioned(
              top: -30,
              right: -50,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            // Content
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ribbon-style "LIMITED TIME" tag
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Title with emphasis
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                height: 1.15,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 6, bottom: 0),
                            child: Text('🍔', style: TextStyle(fontSize: 22)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.92),
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // CTA button
                      Center(
                        child: Material(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          elevation: 0,
                          child: InkWell(
                            onTap: onTap,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    ctaLabel,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
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
    );
  }
}
