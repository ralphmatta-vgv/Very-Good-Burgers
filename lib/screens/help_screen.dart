import 'package:flutter/material.dart';

import '../utils/theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Help & Support'),
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
              'How can we help?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 24),
            _HelpTile(
              title: 'Placing an order',
              body: 'Browse the menu, add items to your cart, choose pickup time, and place your order. You can apply promo codes at checkout.',
            ),
            _HelpTile(
              title: 'Loyalty rewards',
              body: 'Earn 1 Bite for every order. Redeem 10 Bites for \$10 off your order. Your progress is shown on the Rewards tab.',
            ),
            _HelpTile(
              title: 'Express reorder',
              body: 'Go to Order History and tap "Express reorder" on any past order to add those items to your cart instantly.',
            ),
            _HelpTile(
              title: 'Contact us',
              body: 'Email: support@verygoodburgers.com\nPhone: (555) 123-4567\nWe typically respond within 24 hours.',
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  const _HelpTile({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.gray700,
            ),
          ),
        ],
      ),
    );
  }
}
