import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/order.dart';
import 'providers/app_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/user_provider.dart';
import 'screens/home_screen.dart';
import 'screens/order_screen.dart';
import 'screens/loyalty_screen.dart';
import 'screens/profile_screen.dart';
import 'services/braze_service.dart';
import 'utils/theme.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/modals/cart_modal.dart';
import 'widgets/modals/order_confirm_modal.dart';

class VeryGoodBurgersApp extends StatelessWidget {
  const VeryGoodBurgersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Very Good Burgers',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const _MainScaffold(),
    );
  }
}

class _MainScaffold extends StatefulWidget {
  const _MainScaffold();

  @override
  State<_MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<_MainScaffold> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    final names = ['home', 'order', 'rewards', 'profile'];
    if (index < names.length) {
      BrazeService.logCustomEvent('tab_viewed', {'tab_name': names[index]});
    }
  }

  void _showCartModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, __) => CartModal(
          onClose: () => Navigator.of(ctx).pop(),
          onPlaceOrder: (Order order) {
            Navigator.of(ctx).pop();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx2) => OrderConfirmModal(
                order: order,
                onDone: () {
                  Navigator.of(ctx2).pop();
                  _onTabTapped(NavTab.home.index);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Column(
        children: [
          // Header: dark navy bar (logo + cart only)
          SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              color: AppColors.navy,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/icon/app_icon.png',
                    height: 46,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text(
                      'VGB',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Consumer<CartProvider>(
                    builder: (context, cart, _) {
                      return IconButton(
                        icon: Badge(
                          isLabelVisible: cart.itemCount > 0,
                          label: Text(
                            '${cart.itemCount}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                          ),
                          backgroundColor: AppColors.white,
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            color: AppColors.white,
                            size: 24,
                          ),
                        ),
                        onPressed: () => _showCartModal(context),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.white.withValues(alpha: 0.15),
                          foregroundColor: AppColors.white,
                        ),
                      );
                    },
                  ),
                ],
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
                    AppColors.gray100,
                    AppColors.gray200.withValues(alpha: 0.4),
                  ],
                ),
              ),
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  const HomeScreen(),
                  OrderScreen(onOrderConfirmed: () => _onTabTapped(NavTab.home.index)),
                  const LoyaltyScreen(),
                  const ProfileScreen(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, _) => BottomNav(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          cartCount: cart.itemCount,
        ),
      ),
    );
  }
}
