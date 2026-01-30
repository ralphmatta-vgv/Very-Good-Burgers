import 'package:flutter/material.dart';

import '../utils/theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
              '1. Acceptance of Terms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'By accessing and using the Very Good Burgers app, you accept and agree to be bound by these Terms of Service. If you do not agree, please do not use the app.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '2. Use of the App',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You may use this app to browse our menu, place orders for pickup, manage your loyalty rewards, and update your profile. You agree to provide accurate information and to use the app only for lawful purposes.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '3. Orders & Payment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Orders placed through the app are subject to availability and store hours. Payment is collected at pickup. Prices and promotions may change without notice.',
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
