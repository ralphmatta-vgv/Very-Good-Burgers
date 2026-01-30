import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/store.dart';
import '../../data/menu_data.dart';
import '../../providers/app_provider.dart';
import '../../utils/theme.dart';

class StoreModal extends StatelessWidget {
  const StoreModal({
    super.key,
    required this.onClose,
    required this.onStoreSelected,
  });

  final VoidCallback onClose;
  final VoidCallback onStoreSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusModal)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Store',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: MenuData.stores.length,
              itemBuilder: (context, index) {
                final store = MenuData.stores[index];
                return Consumer<AppProvider>(
                  builder: (context, app, _) {
                    final isSelected = app.selectedStore?.id == store.id;
                    return _StoreCard(
                      store: store,
                      isSelected: isSelected,
                      onTap: () {
                        app.setSelectedStore(store);
                        onStoreSelected();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.gray300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.store,
    required this.isSelected,
    required this.onTap,
  });

  final Store store;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.gray200,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📍', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store.address,
                        style: const TextStyle(
                          color: AppColors.gray700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        store.city,
                        style: const TextStyle(
                          color: AppColors.gray500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store.distance,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store.hours,
                        style: const TextStyle(
                          color: AppColors.gray500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 28,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
