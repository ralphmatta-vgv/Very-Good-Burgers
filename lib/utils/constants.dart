/// App-wide constants.
abstract class AppConstants {
  static const String appName = 'Very Good Burgers';
  static const String appVersion = '1.0.0';

  static const double taxRate = 0.08875; // 8.875%
  static const int qualifyingAmountForPoint = 10; // $10 min for 1 point
  static const int pointsPerQualifyingOrder = 1;
  static const int pointsForReward = 10;
  static const double rewardDiscountAmount = 10.0;

  static const List<String> pickupTimeOptions = [
    'asap',
    '30min',
    '45min',
    '1hour',
    'schedule',
  ];

  static String pickupTimeLabel(String key) {
    switch (key) {
      case 'asap':
        return 'ASAP (15-20 min)';
      case '30min':
        return '30 min';
      case '45min':
        return '45 min';
      case '1hour':
        return '1 hour';
      case 'schedule':
        return 'Schedule';
      default:
        return key;
    }
  }
}
