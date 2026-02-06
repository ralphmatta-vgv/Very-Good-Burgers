import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../models/user.dart';
import '../utils/storage_service.dart';
import '../services/braze_tracking.dart';
import '../services/braze_rest.dart';

final _uuid = Uuid();

bool _isUuid(String id) =>
    id.length == 36 && id[8] == '-' && id[13] == '-' && id[18] == '-' && id[23] == '-';

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
    BrazeTracking.changeUser(_user!.id);
    BrazeTracking.setStandardAttributes(firstName: _user!.firstName, lastName: _user!.lastName, email: _user!.email);
    BrazeTracking.setPhone(_user!.phone.isNotEmpty ? _user!.phone : null);
    BrazeTracking.setBirthday(_user!.birthday.isNotEmpty ? _user!.birthday : null);
    BrazeTracking.setHasPayment(_user!.paymentMethods.isNotEmpty);
    _syncSubscriptionState();
    // Migrate legacy external ID (e.g. user_1) to UUID in Braze then locally so we don't create a duplicate.
    if (!_isUuid(_user!.id)) {
      Future.microtask(() => _migrateToUuidAsync(_user!));
    }
  }

  Future<void> _migrateToUuidAsync(User u) async {
    final newId = _uuid.v4();
    final ok = await BrazeRest.renameExternalId(u.id, newId);
    if (!ok) return; // No REST key or API failed; keep existing id.
    _user = User(
      id: newId,
      firstName: u.firstName,
      lastName: u.lastName,
      email: u.email,
      phone: u.phone,
      birthday: u.birthday,
      notificationsEnabled: u.notificationsEnabled,
      emailOffersEnabled: u.emailOffersEnabled,
      smsOffersEnabled: u.smsOffersEnabled,
      profilePhotoFile: u.profilePhotoFile,
      profilePhotoScale: u.profilePhotoScale,
      profilePhotoOffsetX: u.profilePhotoOffsetX,
      profilePhotoOffsetY: u.profilePhotoOffsetY,
      savedAddresses: u.savedAddresses,
      paymentMethods: u.paymentMethods,
    );
    StorageService.saveUser(_user!);
    BrazeTracking.changeUser(_user!.id);
    BrazeTracking.setStandardAttributes(firstName: _user!.firstName, lastName: _user!.lastName, email: _user!.email);
    BrazeTracking.setPhone(_user!.phone.isNotEmpty ? _user!.phone : null);
    BrazeTracking.setBirthday(_user!.birthday.isNotEmpty ? _user!.birthday : null);
    BrazeTracking.setHasPayment(_user!.paymentMethods.isNotEmpty);
    _syncSubscriptionState();
    notifyListeners();
  }

  void _syncSubscriptionState() {
    if (_user == null) return;
    BrazeTracking.setPushSubscription(_user!.notificationsEnabled);
    BrazeTracking.setEmailSubscription(_user!.emailOffersEnabled);
    BrazeTracking.setSMSSubscription(_user!.smsOffersEnabled);
  }

  static User get _defaultUser => User(
        id: _uuid.v4(),
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
      // Sync to Braze when we have a public URL (e.g. after uploading to your CDN). For now we pass null.
      BrazeTracking.setProfileImageUrl(updates['profile_image_url'] as String?);
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
    BrazeTracking.setStandardAttributes(firstName: _user!.firstName, lastName: _user!.lastName, email: _user!.email);
    if (updates.containsKey('phone')) BrazeTracking.setPhone(_user!.phone.isNotEmpty ? _user!.phone : null);
    if (updates.containsKey('birthday')) BrazeTracking.setBirthday(_user!.birthday.isNotEmpty ? _user!.birthday : null);
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
    BrazeTracking.trackPaymentMethodPrimaryChanged(paymentMethodId);
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
    BrazeTracking.trackNotificationPreferenceChanged(type: type, enabled: enabled);
    BrazeTracking.setPushSubscription(_user!.notificationsEnabled);
    BrazeTracking.setEmailSubscription(_user!.emailOffersEnabled);
    BrazeTracking.setSMSSubscription(_user!.smsOffersEnabled);
    notifyListeners();
  }

  /// Call when user turns Push on: requests OS notification permission, then updates preference and Braze.
  /// If permission is denied, preference stays off.
  Future<void> setPushPreferenceWithPermission(bool enabled) async {
    if (_user == null) return;
    if (enabled) {
      final status = await Permission.notification.request();
      enabled = status.isGranted;
    }
    setNotificationPreference('push', enabled);
  }
}
