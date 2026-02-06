import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/app_provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/profile_photo_editor.dart';
import 'terms_screen.dart';
import 'privacy_screen.dart';
import 'help_screen.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.onSwitchToOrder});

  final VoidCallback? onSwitchToOrder;

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
                      GestureDetector(
                        onTap: () => _pickAndEditProfilePhoto(context, userProv),
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: _ProfileAvatar(user: user),
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
                          _StatChip(label: 'Bites', value: '${appProv.loyaltyPoints}'),
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
              title: 'Order History',
              children: [
                _ListTile(
                  leading: const Text('📜', style: TextStyle(fontSize: 20)),
                  title: const Text('View order history'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OrderHistoryScreen(
                        onExpressReorder: () {
                          Navigator.of(context).pop();
                          onSwitchToOrder?.call();
                        },
                      ),
                    ),
                  ),
                ),
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
                                      child: const Text('Primary', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                    )
                                  : const Text('Tap to set Primary', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
                              onTap: pm.isDefault ? null : () => userProv.setPrimaryPaymentMethod(pm.id),
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
                _ListTile(
                  leading: const Text('📋', style: TextStyle(fontSize: 20)),
                  title: const Text('Terms of Service'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TermsScreen()),
                  ),
                ),
                _ListTile(
                  leading: const Text('🔒', style: TextStyle(fontSize: 20)),
                  title: const Text('Privacy Policy'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                  ),
                ),
                _ListTile(
                  leading: const Text('❓', style: TextStyle(fontSize: 20)),
                  title: const Text('Help & Support'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HelpScreen()),
                  ),
                ),
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.user});

  final User user;

  static const double _displaySize = 80;
  static const double _refSize = ProfilePhotoEditor.referenceSize;

  @override
  Widget build(BuildContext context) {
    final file = user.profilePhotoFile;
    if (file == null || file.isEmpty) {
      return ClipOval(
        child: Image.asset(
          'assets/images/profile_photo.png',
          width: _displaySize,
          height: _displaySize,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsPlaceholder(),
        ),
      );
    }
    return FutureBuilder<String>(
      future: _profilePhotoPath(file),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _initialsPlaceholder();
        final path = snapshot.data!;
        final f = File(path);
        if (!f.existsSync()) return _initialsPlaceholder();
        final scale = user.profilePhotoScale ?? 1.0;
        final ox = (user.profilePhotoOffsetX ?? 0) * (_displaySize / _refSize);
        final oy = (user.profilePhotoOffsetY ?? 0) * (_displaySize / _refSize);
        return ClipOval(
          child: SizedBox(
            width: _displaySize,
            height: _displaySize,
            child: OverflowBox(
              maxWidth: _displaySize * 2,
              maxHeight: _displaySize * 2,
              alignment: Alignment.center,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translate(ox, oy)
                  ..scale(scale),
                child: Image.file(
                  f,
                  width: _displaySize * 2,
                  height: _displaySize * 2,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String> _profilePhotoPath(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$filename';
  }

  Widget _initialsPlaceholder() {
    return Container(
      width: _displaySize,
      height: _displaySize,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        user.initials,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Future<void> _pickAndEditProfilePhoto(BuildContext context, UserProvider userProv) async {
  final picker = ImagePicker();
  final xFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
  if (xFile == null || !context.mounted) return;
  final file = File(xFile.path);
  if (!file.existsSync()) return;
  if (!context.mounted) return;
  await Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (ctx) => ProfilePhotoEditor(
        imageFile: file,
        onCancel: () => Navigator.of(ctx).pop(),
        onConfirm: (scale, offsetX, offsetY) async {
          final dir = await getApplicationDocumentsDirectory();
          final filename = 'profile_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final dest = File('${dir.path}/$filename');
          await file.copy(dest.path);
          if (!ctx.mounted) return;
          userProv.updateProfile({
            'profilePhotoFile': filename,
            'profilePhotoScale': scale,
            'profilePhotoOffsetX': offsetX,
            'profilePhotoOffsetY': offsetY,
          });
          Navigator.of(ctx).pop();
        },
      ),
    ),
  );
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
    if (fieldKey == 'birthday') {
      _showBirthdayPicker(context, userProv, initialValue);
      return;
    }
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
                  hintText: fieldKey == 'phone' ? '(555) 555-1234' : label,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: fieldKey == 'phone' ? TextInputType.phone : TextInputType.text,
                inputFormatters: fieldKey == 'phone' ? [_PhoneFormatter()] : null,
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

  void _showBirthdayPicker(BuildContext context, UserProvider userProv, String initialValue) {
    DateTime initial = DateTime(1990, 1, 1);
    if (initialValue.isNotEmpty) {
      try {
        final parts = initialValue.trim().split(RegExp(r'[-/]'));
        if (parts.length >= 3) {
          int year;
          int month;
          int day;
          if (parts[0].length == 4) {
            year = int.parse(parts[0]);
            month = int.parse(parts[1]);
            day = int.parse(parts[2]);
          } else {
            month = int.parse(parts[0]);
            day = int.parse(parts[1]);
            year = int.parse(parts[2]);
          }
          initial = DateTime(year, month.clamp(1, 12), day.clamp(1, 31));
        } else if (initialValue.length >= 8) {
          initial = DateTime.parse(initialValue.replaceAll('/', '-'));
        }
      } catch (_) {}
    }
    if (initial.isBefore(DateTime(1900, 1, 1)) || initial.isAfter(DateTime.now())) {
      initial = DateTime(1990, 1, 1);
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BirthdayPickerSheet(
        initial: initial,
        onSave: (month, day, year) {
          final s = '${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}/$year';
          userProv.updateProfile({'birthday': s});
          Navigator.of(ctx).pop();
        },
        onCancel: () => Navigator.of(ctx).pop(),
      ),
    );
  }
}

/// Month, Day, Year scrollable picker (order: Month, Day, Year).
class _BirthdayPickerSheet extends StatefulWidget {
  const _BirthdayPickerSheet({
    required this.initial,
    required this.onSave,
    required this.onCancel,
  });

  final DateTime initial;
  final void Function(int month, int day, int year) onSave;
  final VoidCallback onCancel;

  @override
  State<_BirthdayPickerSheet> createState() => _BirthdayPickerSheetState();
}

class _BirthdayPickerSheetState extends State<_BirthdayPickerSheet> {
  static const List<String> monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  late int selectedMonth;
  late int selectedDay;
  late int selectedYear;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _yearController;
  late List<int> years;

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initial.month;
    selectedYear = widget.initial.year;
    years = List.generate(DateTime.now().year - 1900 + 1, (i) => 1900 + i).reversed.toList();
    final daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    selectedDay = widget.initial.day.clamp(1, daysInMonth);
    _monthController = FixedExtentScrollController(initialItem: selectedMonth - 1);
    _dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    _yearController = FixedExtentScrollController(initialItem: years.indexOf(selectedYear).clamp(0, years.length - 1));
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  int get daysInMonth => DateTime(selectedYear, selectedMonth + 1, 0).day;

  void _onMonthChanged(int i) {
    setState(() {
      selectedMonth = i + 1;
      final newDays = daysInMonth;
      selectedDay = selectedDay.clamp(1, newDays);
      _dayController.dispose();
      _dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    });
  }

  void _onYearChanged(int i) {
    setState(() {
      selectedYear = years[i];
      final newDays = daysInMonth;
      selectedDay = selectedDay.clamp(1, newDays);
      _dayController.dispose();
      _dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (selectedDay > daysInMonth) {
      selectedDay = daysInMonth;
    }
    final days = List.generate(daysInMonth, (i) => i + 1);
    return Container(
      height: 320,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
                const Text('Date of Birth', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => widget.onSave(selectedMonth, selectedDay, selectedYear),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 36,
                    scrollController: _monthController,
                    onSelectedItemChanged: _onMonthChanged,
                    selectionOverlay: null,
                    children: monthNames.asMap().entries.map((e) => Center(
                      child: Text('${e.key + 1}. ${e.value}', style: const TextStyle(fontSize: 18, color: AppColors.navy)),
                    )).toList(),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 36,
                    scrollController: _dayController,
                    onSelectedItemChanged: (i) => setState(() => selectedDay = days[i]),
                    selectionOverlay: null,
                    children: days.map((d) => Center(
                      child: Text('$d', style: const TextStyle(fontSize: 18, color: AppColors.navy)),
                    )).toList(),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 36,
                    scrollController: _yearController,
                    onSelectedItemChanged: _onYearChanged,
                    selectionOverlay: null,
                    children: years.map((y) => Center(
                      child: Text('$y', style: const TextStyle(fontSize: 18, color: AppColors.navy)),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Formats phone input as (XXX) XXX-XXXX (space after closing paren).
class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 10 ? digits.substring(0, 10) : digits;
    if (limited.isEmpty) {
      return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }
    // Always (XXX) XXX-XXXX with space after )
    String formatted;
    if (limited.length <= 3) {
      formatted = '($limited';
    } else if (limited.length <= 6) {
      formatted = '(${limited.substring(0, 3)}) ${limited.substring(3)}';
    } else {
      formatted = '(${limited.substring(0, 3)}) ${limited.substring(3, 6)}-${limited.substring(6)}';
    }
    // Cursor: number of digits that should appear before cursor in formatted string
    final cursorPos = newValue.selection.baseOffset.clamp(0, newValue.text.length);
    final digitsBeforeCursor = newValue.text
        .substring(0, cursorPos)
        .replaceAll(RegExp(r'\D'), '')
        .length
        .clamp(0, limited.length);
    // Place cursor after the Nth digit in formatted string so typing stays in sequence
    int cursorOffset = formatted.length;
    if (digitsBeforeCursor == 0) {
      cursorOffset = 0;
    } else {
      int count = 0;
      for (int i = 0; i < formatted.length; i++) {
        if (RegExp(r'\d').hasMatch(formatted[i])) {
          count++;
          if (count == digitsBeforeCursor) {
            cursorOffset = i + 1;
            break;
          }
        }
      }
    }
    cursorOffset = cursorOffset.clamp(0, formatted.length);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorOffset),
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
            onChanged: (v) {
              if (keyName == 'push') {
                userProv.setPushPreferenceWithPermission(v);
              } else {
                userProv.setNotificationPreference(keyName, v);
              }
            },
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
