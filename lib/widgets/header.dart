import 'package:flutter/material.dart';

import '../utils/theme.dart';

class VGBHeader extends StatelessWidget {
  const VGBHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.backgroundColor,
  });

  final String title;
  final String? subtitle;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.navy,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.gray300,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          if (subtitle != null) const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
