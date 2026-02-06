import 'dart:async';

import 'package:braze_plugin/braze_plugin.dart';
import 'package:flutter/foundation.dart';

import '../services/braze_service.dart';

/// Holds Braze Content Cards for the home screen. Subscribes to the Braze stream and
/// loads cached cards on init so cards appear immediately and update when Braze refreshes.
class ContentCardsProvider extends ChangeNotifier {
  ContentCardsProvider() {
    _subscription = BrazeService.plugin?.subscribeToContentCards(_onContentCards);
    _loadCached();
    BrazeService.requestContentCardsRefresh();
  }

  StreamSubscription<dynamic>? _subscription;
  List<BrazeContentCard> _cards = [];
  bool _loading = true;

  List<BrazeContentCard> get cards => List.unmodifiable(_cards);
  bool get loading => _loading;

  /// Cards suitable for display: not removed, not control, not expired.
  List<BrazeContentCard> get displayCards {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return _cards.where((c) {
      if (c.removed || c.isControl) return false;
      if (c.expiresAt > 0 && c.expiresAt < now) return false;
      return true;
    }).toList();
  }

  void _onContentCards(List<BrazeContentCard> list) {
    _cards = list;
    _loading = false;
    notifyListeners();
  }

  Future<void> _loadCached() async {
    try {
      final cached = await BrazeService.getCachedContentCards();
      if (cached.isNotEmpty) {
        _cards = cached;
        _loading = false;
        notifyListeners();
      }
    } catch (_) {
      _loading = false;
      notifyListeners();
    }
  }

  void refresh() {
    BrazeService.requestContentCardsRefresh();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
