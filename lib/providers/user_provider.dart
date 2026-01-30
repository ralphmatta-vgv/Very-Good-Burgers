import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../utils/storage_service.dart';
import '../services/braze_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  UserProvider() {
    _user = StorageService.getUser();
    if (_user == null) {
      _user = _defaultUser;
      StorageService.saveUser(_user!);
    } else if (_user!.firstName == 'John' && _user!.lastName == 'Doe') {
      _user!.firstName = 'Ralph';
      _user!.lastName = 'Matta';
      _user!.email = 'ralph.matta@example.com';
      StorageService.saveUser(_user!);
    }
    BrazeService.changeUser(_user!.id);
  }

  static User get _defaultUser => User(
        id: 'user_1',
        firstName: 'Ralph',
        lastName: 'Matta',
        email: 'ralph.matta@example.com',
        phone: '(555) 123-4567',
        birthday: '1990-05-15',
        notificationsEnabled: true,
        emailOffersEnabled: true,
        smsOffersEnabled: false,
        savedAddresses: [
          SavedAddress(id: 'addr1', label: 'Home', street: '123 Elm Street, Apt 4B', city: 'New York', state: 'NY', zip: '10001'),
          SavedAddress(id: 'addr2', label: 'Work', street: '456 Corporate Plaza', city: 'New York', state: 'NY', zip: '10018'),
        ],
        paymentMethods: [
          PaymentMethod(id: 'pm1', brand: 'Visa', last4: '4242', isDefault: true),
          PaymentMethod(id: 'pm2', brand: 'Mastercard', last4: '8888', isDefault: false),
        ],
      );

  void updateProfile(Map<String, dynamic> updates) {
    if (_user == null) return;
    final fields = <String>[];
    if (updates.containsKey('firstName')) {
      _user!.firstName = updates['firstName'] as String;
      fields.add('firstName');
    }
    if (updates.containsKey('lastName')) {
      _user!.lastName = updates['lastName'] as String;
      fields.add('lastName');
    }
    if (updates.containsKey('email')) {
      _user!.email = updates['email'] as String;
      fields.add('email');
    }
    if (updates.containsKey('phone')) {
      _user!.phone = updates['phone'] as String;
      fields.add('phone');
    }
    if (updates.containsKey('birthday')) {
      _user!.birthday = updates['birthday'] as String;
      fields.add('birthday');
    }
    if (updates.containsKey('profilePhotoFile')) {
      _user!.profilePhotoFile = updates['profilePhotoFile'] as String?;
      fields.add('profilePhotoFile');
    }
    if (updates.containsKey('profilePhotoScale')) {
      _user!.profilePhotoScale = updates['profilePhotoScale'] as double?;
    }
    if (updates.containsKey('profilePhotoOffsetX')) {
      _user!.profilePhotoOffsetX = updates['profilePhotoOffsetX'] as double?;
    }
    if (updates.containsKey('profilePhotoOffsetY')) {
      _user!.profilePhotoOffsetY = updates['profilePhotoOffsetY'] as double?;
    }
    StorageService.saveUser(_user!);
    for (final k in ['firstName', 'last_name', 'email', 'phone', 'birthday']) {
      if (updates.containsKey(k)) {
        BrazeService.setUserAttribute(k, updates[k]);
      }
    }
    BrazeService.logCustomEvent('profile_updated', {'updated_fields': fields});
    notifyListeners();
  }

  void setPrimaryPaymentMethod(String paymentMethodId) {
    if (_user == null) return;
    _user!.paymentMethods = _user!.paymentMethods
        .map((pm) => PaymentMethod(
              id: pm.id,
              brand: pm.brand,
              last4: pm.last4,
              isDefault: pm.id == paymentMethodId,
            ))
        .toList();
    StorageService.saveUser(_user!);
    BrazeService.logCustomEvent('payment_method_primary_changed', {'id': paymentMethodId});
    notifyListeners();
  }

  void setNotificationPreference(String type, bool enabled) {
    if (_user == null) return;
    switch (type) {
      case 'push':
        _user!.notificationsEnabled = enabled;
        break;
      case 'email':
        _user!.emailOffersEnabled = enabled;
        break;
      case 'sms':
        _user!.smsOffersEnabled = enabled;
        break;
    }
    StorageService.saveUser(_user!);
    BrazeService.logCustomEvent('notification_preference_changed', {'type': type, 'enabled': enabled});
    notifyListeners();
  }
}
