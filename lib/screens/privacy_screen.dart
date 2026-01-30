import 'package:flutter/material.dart';

import '../utils/theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last updated: January 2026',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Information We Collect',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We collect information you provide when you create an account, place an order, or contact us. This may include your name, email, phone number, delivery address, and payment details. We also collect usage data to improve the app.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'How We Use Your Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We use your information to process orders, send order updates, manage loyalty rewards, and send promotional offers (with your consent). We do not sell your personal information to third parties.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Data Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We implement appropriate security measures to protect your personal information. Payment details are processed by secure, certified providers.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
