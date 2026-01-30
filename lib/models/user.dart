/// Saved address for delivery or profile.
class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
  });

  final String id;
  final String label;
  final String street;
  final String city;
  final String state;
  final String zip;

  String get fullAddress => '$street, $city, $state $zip';

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'street': street,
        'city': city,
        'state': state,
        'zip': zip,
      };

  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
        id: json['id'] as String,
        label: json['label'] as String,
        street: json['street'] as String,
        city: json['city'] as String,
        state: json['state'] as String,
        zip: json['zip'] as String,
      );
}

/// Saved payment method.
class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.brand,
    required this.last4,
    this.isDefault = false,
  });

  final String id;
  final String brand;
  final String last4;
  final bool isDefault;

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand': brand,
        'last4': last4,
        'isDefault': isDefault,
      };

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        id: json['id'] as String,
        brand: json['brand'] as String,
        last4: json['last4'] as String,
        isDefault: json['isDefault'] as bool? ?? false,
      );
}

/// App user profile.
class User {
  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone = '',
    this.birthday = '',
    this.notificationsEnabled = true,
    this.emailOffersEnabled = true,
    this.smsOffersEnabled = false,
    this.profilePhotoFile,
    this.profilePhotoScale,
    this.profilePhotoOffsetX,
    this.profilePhotoOffsetY,
    List<SavedAddress>? savedAddresses,
    List<PaymentMethod>? paymentMethods,
  })  : savedAddresses = savedAddresses ?? [],
        paymentMethods = paymentMethods ?? [];

  final String id;
  String firstName;
  String lastName;
  String email;
  String phone;
  String birthday;
  bool notificationsEnabled;
  bool emailOffersEnabled;
  bool smsOffersEnabled;
  /// Filename for profile photo stored in app documents directory.
  String? profilePhotoFile;
  /// Scale used in circular frame (e.g. 1.0 = fit).
  double? profilePhotoScale;
  /// Offset X for positioning in circular frame.
  double? profilePhotoOffsetX;
  /// Offset Y for positioning in circular frame.
  double? profilePhotoOffsetY;
  List<SavedAddress> savedAddresses;
  List<PaymentMethod> paymentMethods;

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'birthday': birthday,
        'notificationsEnabled': notificationsEnabled,
        'emailOffersEnabled': emailOffersEnabled,
        'smsOffersEnabled': smsOffersEnabled,
        'profilePhotoFile': profilePhotoFile,
        'profilePhotoScale': profilePhotoScale,
        'profilePhotoOffsetX': profilePhotoOffsetX,
        'profilePhotoOffsetY': profilePhotoOffsetY,
        'savedAddresses': savedAddresses.map((e) => e.toJson()).toList(),
        'paymentMethods': paymentMethods.map((e) => e.toJson()).toList(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String? ?? '',
        birthday: json['birthday'] as String? ?? '',
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
        emailOffersEnabled: json['emailOffersEnabled'] as bool? ?? true,
        smsOffersEnabled: json['smsOffersEnabled'] as bool? ?? false,
        profilePhotoFile: json['profilePhotoFile'] as String?,
        profilePhotoScale: (json['profilePhotoScale'] as num?)?.toDouble(),
        profilePhotoOffsetX: (json['profilePhotoOffsetX'] as num?)?.toDouble(),
        profilePhotoOffsetY: (json['profilePhotoOffsetY'] as num?)?.toDouble(),
        savedAddresses: (json['savedAddresses'] as List<dynamic>?)
                ?.map((e) => SavedAddress.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        paymentMethods: (json['paymentMethods'] as List<dynamic>?)
                ?.map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
