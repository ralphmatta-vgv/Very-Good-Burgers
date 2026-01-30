import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/app_provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
              decoration: const BoxDecoration(color: AppColors.navy),
              child: Consumer2<UserProvider, AppProvider>(
                builder: (context, userProv, appProv, _) {
                  final user = userProv.user;
                  if (user == null) return const SizedBox.shrink();
                  return Column(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/profile_photo.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.primary,
                              alignment: Alignment.center,
                              child: Text(
                                user.initials,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: AppColors.gray300,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _StatChip(label: 'Points', value: '${appProv.loyaltyPoints}'),
                          const SizedBox(width: 16),
                          _StatChip(label: 'Orders', value: '${appProv.orderHistory.length}'),
                          const SizedBox(width: 16),
                          _StatChip(label: 'Cards', value: '${user.paymentMethods.length}'),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _Section(
              title: 'Personal Information',
              children: [
                _ProfileField(icon: '👤', label: 'First Name', fieldKey: 'firstName'),
                _ProfileField(icon: '👤', label: 'Last Name', fieldKey: 'lastName'),
                _ProfileField(icon: '📧', label: 'Email', fieldKey: 'email'),
                _ProfileField(icon: '📱', label: 'Phone', fieldKey: 'phone'),
                _ProfileField(icon: '🎂', label: 'Birthday', fieldKey: 'birthday'),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: _Section(
              title: 'Notification Preferences',
              children: [
                _ToggleRow(
                  icon: '🔔',
                  label: 'Push Notifications',
                  keyName: 'push',
                ),
                _ToggleRow(
                  icon: '📧',
                  label: 'Email Offers',
                  keyName: 'email',
                ),
                _ToggleRow(
                  icon: '💬',
                  label: 'SMS Offers',
                  keyName: 'sms',
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: _Section(
              title: 'Payment Methods',
              children: [
                Consumer<UserProvider>(
                  builder: (context, userProv, _) {
                    final methods = userProv.user?.paymentMethods ?? [];
                    return Column(
                      children: [
                        ...methods.map((pm) => _ListTile(
                              leading: const Text('💳', style: TextStyle(fontSize: 24)),
                              title: Text('${pm.brand} •••• ${pm.last4}'),
                              trailing: pm.isDefault
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('Default', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                    )
                                  : null,
                            )),
                        _ListTile(
                          leading: const Icon(Icons.add, color: AppColors.primary),
                          title: const Text('Add Payment Method', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                          onTap: () {},
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: _Section(
              title: 'Saved Addresses',
              children: [
                Consumer<UserProvider>(
                  builder: (context, userProv, _) {
                    final addresses = userProv.user?.savedAddresses ?? [];
                    return Column(
                      children: [
                        ...addresses.map((addr) => _ListTile(
                              leading: const Text('📍', style: TextStyle(fontSize: 24)),
                              title: Text('${addr.label}: ${addr.street}...'),
                              onTap: () {},
                            )),
                        _ListTile(
                          leading: const Icon(Icons.add, color: AppColors.primary),
                          title: const Text('Add Address', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                          onTap: () {},
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: _Section(
              title: 'App',
              children: [
                _ListTile(leading: const Text('📋', style: TextStyle(fontSize: 20)), title: const Text('Terms of Service'), onTap: () {}),
                _ListTile(leading: const Text('🔒', style: TextStyle(fontSize: 20)), title: const Text('Privacy Policy'), onTap: () {}),
                _ListTile(leading: const Text('❓', style: TextStyle(fontSize: 20)), title: const Text('Help & Support'), onTap: () {}),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const SizedBox(
                  width: double.infinity,
                  child: Text('Sign Out', textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'Version ${AppConstants.appVersion}',
                  style: const TextStyle(color: AppColors.gray500, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.gray300,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gray300.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.icon,
    required this.label,
    required this.fieldKey,
  });

  final String icon;
  final String label;
  final String fieldKey;

  String _getValue(User? user) {
    if (user == null) return '';
    switch (fieldKey) {
      case 'firstName': return user.firstName;
      case 'lastName': return user.lastName;
      case 'email': return user.email;
      case 'phone': return user.phone;
      case 'birthday': return user.birthday;
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProv, _) {
        final value = _getValue(userProv.user);
        return _ListTile(
          leading: Text(icon, style: const TextStyle(fontSize: 20)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.gray500, fontSize: 12)),
              Text(value.isEmpty ? '—' : value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          trailing: Icon(Icons.edit_outlined, size: 20, color: AppColors.gray500),
          onTap: () => _showEditModal(context, userProv, value),
        );
      },
    );
  }

  void _showEditModal(BuildContext context, UserProvider userProv, String initialValue) {
    final controller = TextEditingController(text: initialValue);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Edit $label', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: label,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  userProv.updateProfile({fieldKey: controller.text});
                  Navigator.of(ctx).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.keyName,
  });

  final String icon;
  final String label;
  final String keyName;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProv, _) {
        final user = userProv.user;
        if (user == null) return const SizedBox.shrink();
        bool enabled;
        switch (keyName) {
          case 'push':
            enabled = user.notificationsEnabled;
            break;
          case 'email':
            enabled = user.emailOffersEnabled;
            break;
          case 'sms':
            enabled = user.smsOffersEnabled;
            break;
          default:
            enabled = false;
        }
        return _ListTile(
          leading: Text(icon, style: const TextStyle(fontSize: 20)),
          title: Text(label),
          trailing: CupertinoSwitch(
            value: enabled,
            onChanged: (v) => userProv.setNotificationPreference(keyName, v),
            activeColor: AppColors.primary,
          ),
        );
      },
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    required this.leading,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final Widget leading;
  final Widget title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(child: title),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
