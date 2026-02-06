import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/menu_data.dart';
import 'models/menu_item.dart';
import 'models/order.dart';
import 'providers/app_provider.dart';
import 'providers/cart_provider.dart';
import 'utils/constants.dart';
import 'screens/home_screen.dart';
import 'screens/order_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/loyalty_screen.dart';
import 'screens/profile_screen.dart';
import 'services/braze_tracking.dart';
import 'utils/theme.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/braze_in_app_message_handler.dart';
import 'widgets/modals/cart_modal.dart';
import 'widgets/modals/order_confirm_modal.dart';
import 'widgets/modals/store_modal.dart';

class VeryGoodBurgersApp extends StatelessWidget {
  const VeryGoodBurgersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Very Good Burgers',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const BrazeInAppMessageHandler(child: _MainScaffold()),
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
  MenuItem? _pendingOrderItem;
  MenuItem? _pendingRewardItem;

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    final names = ['home', 'order', 'rewards', 'profile'];
    if (index < names.length) {
      BrazeTracking.trackTabViewed(names[index]);
    }
  }

  void _onOrderNowDoubleSmash(BuildContext context) {
    context.read<AppProvider>().applyCoupon(AppConstants.doubleSmashCouponCode);
    setState(() {
      _pendingOrderItem = MenuData.getItemById('b_double_smash');
      _currentIndex = NavTab.order.index;
    });
    BrazeTracking.trackTabViewed('order');
  }

  void _clearPendingOrderItem() {
    setState(() => _pendingOrderItem = null);
  }

  void _onRedeemRewardItem(MenuItem item) {
    setState(() {
      _pendingRewardItem = item;
      _currentIndex = NavTab.order.index;
    });
    BrazeTracking.trackTabViewed('order');
  }

  void _clearPendingRewardItem() {
    setState(() => _pendingRewardItem = null);
  }

  void _showStoreModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StoreModal(
        onClose: () => Navigator.of(ctx).pop(),
        onStoreSelected: () => Navigator.of(ctx).pop(),
      ),
    );
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
    final isHome = _currentIndex == NavTab.home.index;
    final isOrder = _currentIndex == NavTab.order.index;
    final isRewards = _currentIndex == NavTab.rewards.index;
    final showHeader = !isHome && !isOrder && !isRewards;
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Column(
        children: [
          // Navy header only for Profile (home has own bar; order/rewards no header)
          if (showHeader)
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
                  HomeScreen(
                    onOrderNow: () => _onOrderNowDoubleSmash(context),
                    onTapOrder: () => _onTabTapped(NavTab.order.index),
                    onTapRewards: () => _onTabTapped(NavTab.rewards.index),
                    onTapHistory: () => _onTabTapped(NavTab.profile.index),
                    onOpenOrderHistory: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderHistoryScreen(
                            onExpressReorder: () {
                              Navigator.of(context).pop();
                              _onTabTapped(NavTab.order.index);
                            },
                          ),
                        ),
                      );
                    },
                    onShowCart: () => _showCartModal(context),
                    onShowStoreModal: () => _showStoreModal(context),
                  ),
                  OrderScreen(
                    onOrderConfirmed: () => _onTabTapped(NavTab.home.index),
                    pendingItem: _pendingOrderItem,
                    onClearPendingItem: _clearPendingOrderItem,
                    pendingRewardItem: _pendingRewardItem,
                    onClearPendingRewardItem: _clearPendingRewardItem,
                    onOpenOrderHistory: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderHistoryScreen(
                            onExpressReorder: () {
                              Navigator.of(context).pop();
                              _onTabTapped(NavTab.order.index);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  LoyaltyScreen(onRedeemRewardItem: _onRedeemRewardItem),
                  ProfileScreen(onSwitchToOrder: () => _onTabTapped(NavTab.order.index)),
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
