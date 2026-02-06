import 'dart:async';
import 'dart:io';

import 'package:braze_plugin/braze_plugin.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/braze_service.dart';
import '../utils/theme.dart';

/// Colors for in-app message UI. Parse from Braze extras so dashboard choices match the app.
class _InAppMessageColors {
  _InAppMessageColors.fromMessage(BrazeInAppMessage message) {
    final e = message.extras;
    primary = _parseColor(e['primary_color'] ?? e['button_color']) ?? AppColors.primary;
    iconBackground = _parseColor(e['icon_background_color']) ?? AppColors.primaryLight.withValues(alpha: 0.25);
    iconColor = _parseColor(e['icon_color']) ?? AppColors.primary;
  }

  late final Color primary;
  late final Color iconBackground;
  late final Color iconColor;

  static Color? _parseColor(Object? value) {
    final hex = value?.toString().trim();
    if (hex == null || hex.isEmpty) return null;
    String s = hex.startsWith('#') ? hex.substring(1) : hex;
    if (s.length == 6) s = 'FF$s';
    if (s.length != 8) return null;
    final n = int.tryParse(s, radix: 16);
    return n != null ? Color(n) : null;
  }
}

/// Listens for Braze in-app messages and displays them (modal, full, or slideup).
/// Wrap your app content with this so campaigns created in Braze show in the app.
class BrazeInAppMessageHandler extends StatefulWidget {
  const BrazeInAppMessageHandler({super.key, required this.child});

  final Widget child;

  @override
  State<BrazeInAppMessageHandler> createState() => _BrazeInAppMessageHandlerState();
}

class _BrazeInAppMessageHandlerState extends State<BrazeInAppMessageHandler> {
  StreamSubscription<dynamic>? _subscription;

  @override
  void initState() {
    super.initState();
    final plugin = BrazeService.plugin;
    if (plugin != null) {
      // Show any messages that arrived before we mounted (e.g. session start).
      for (final msg in BrazeService.drainPendingInAppMessages()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showMessage(msg);
        });
      }
      _subscription = plugin.subscribeToInAppMessages(_onInAppMessage);
      // Now we're ready; don't buffer future messages to pending.
      BrazeService.setInAppMessageHandlerMounted(true);
    }
  }

  @override
  void dispose() {
    BrazeService.setInAppMessageHandlerMounted(false);
    _subscription?.cancel();
    super.dispose();
  }

  void _onInAppMessage(BrazeInAppMessage message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showMessage(message);
    });
  }

  void _showMessage(BrazeInAppMessage message) {
    if (!mounted) return;
    BrazeService.plugin?.logInAppMessageImpression(message);

    switch (message.messageType) {
      case MessageType.slideup:
        _showSlideup(message);
        break;
      case MessageType.modal:
        _showModal(message);
        break;
      case MessageType.full:
      case MessageType.html_full:
        _showFullScreen(message);
        break;
      case MessageType.html:
        // HTML (non-full) shown as modal; custom HTML body not rendered, use header/message/buttons
        _showModal(message);
        break;
    }
  }

  void _dismissAndHide(BrazeInAppMessage message) {
    BrazeService.plugin?.hideCurrentInAppMessage();
  }

  void _showModal(BrazeInAppMessage message) {
    final duration = message.dismissType == DismissType.auto_dismiss && message.duration > 0
        ? Duration(milliseconds: message.duration)
        : null;

    showDialog<void>(
      context: context,
      barrierDismissible: message.dismissType == DismissType.swipe,
      builder: (ctx) {
        if (duration != null) {
          Future.delayed(duration, () {
            if (Navigator.of(ctx).canPop()) {
              Navigator.of(ctx).pop();
              _dismissAndHide(message);
            }
          });
        }
        return _InAppMessageDialog(
          message: message,
          onDismiss: () {
            Navigator.of(ctx).pop();
            _dismissAndHide(message);
          },
          onButtonTap: (button) {
            BrazeService.plugin?.logInAppMessageButtonClicked(message, button.id);
            if (button.uri.isNotEmpty) {
              // Optional: open URL (e.g. via url_launcher). For now just dismiss.
            }
            Navigator.of(ctx).pop();
            _dismissAndHide(message);
          },
        );
      },
    ).then((_) => _dismissAndHide(message));
  }

  void _showFullScreen(BrazeInAppMessage message) {
    final duration = message.dismissType == DismissType.auto_dismiss && message.duration > 0
        ? Duration(milliseconds: message.duration)
        : null;

    Navigator.of(context).push<void>(
      PageRouteBuilder(
        fullscreenDialog: true,
        opaque: true,
        barrierColor: Colors.black,
        pageBuilder: (ctx, _, __) {
          if (duration != null) {
            Future.delayed(duration, () {
              if (Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
                _dismissAndHide(message);
              }
            });
          }
          return _InAppMessageFullScreen(
            message: message,
            onDismiss: () {
              Navigator.of(ctx).pop();
              _dismissAndHide(message);
            },
            onButtonTap: (button) {
              BrazeService.plugin?.logInAppMessageButtonClicked(message, button.id);
              if (button.uri.isNotEmpty) {
                // Optional: open URL (e.g. via url_launcher)
              }
              Navigator.of(ctx).pop();
              _dismissAndHide(message);
            },
          );
        },
      ),
    ).then((_) => _dismissAndHide(message));
  }

  void _showSlideup(BrazeInAppMessage message) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _InAppMessageSlideup(
        message: message,
        onDismiss: () {
          Navigator.of(ctx).pop();
          _dismissAndHide(message);
        },
        onButtonTap: (button) {
          BrazeService.plugin?.logInAppMessageButtonClicked(message, button.id);
          if (button.uri.isNotEmpty) {
            // Optional: open URL
          }
          Navigator.of(ctx).pop();
          _dismissAndHide(message);
        },
      ),
    ).then((_) => _dismissAndHide(message));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _InAppMessageDialog extends StatelessWidget {
  const _InAppMessageDialog({
    required this.message,
    required this.onDismiss,
    required this.onButtonTap,
  });

  final BrazeInAppMessage message;
  final VoidCallback onDismiss;
  final void Function(BrazeButton) onButtonTap;

  @override
  Widget build(BuildContext context) {
    final buttons = message.buttons;
    final colors = _InAppMessageColors.fromMessage(message);
    final textDark = AppColors.navy;
    final textMuted = AppColors.gray700;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.white,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Full-width header image when user uploads their own (modal matches Braze preview)
              if (message.imageUrl.isNotEmpty)
                _InAppMessageHeaderImage(
                  url: message.imageUrl,
                  placeholderIconBg: colors.iconBackground,
                  placeholderIconColor: colors.iconColor,
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Small icon placeholder only when no image URL (icon-style message)
                      if (message.imageUrl.isEmpty) ...[
                        Center(
                          child: _InAppMessageImage(
                            url: message.imageUrl,
                            size: 80,
                            placeholderIconBg: colors.iconBackground,
                            placeholderIconColor: colors.iconColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Title – centered, bold (brand dark)
              if (message.header.isNotEmpty)
                Text(
                  message.header,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              if (message.header.isNotEmpty && message.message.isNotEmpty) const SizedBox(height: 8),
              // Body – centered (brand muted)
              if (message.message.isNotEmpty)
                Text(
                  message.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textMuted),
                ),
              // Buttons – use Braze primary_color when set; first = outline, second = filled
              if (buttons.isNotEmpty) ...[
                const SizedBox(height: 24),
                if (buttons.length == 1)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => onButtonTap(buttons[0]),
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: AppColors.white,
                      ),
                      child: Text(buttons[0].text.isNotEmpty ? buttons[0].text.toUpperCase() : 'OK'),
                    ),
                  )
                else if (buttons.length >= 2)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => onButtonTap(buttons[0]),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.primary,
                            side: BorderSide(color: colors.primary),
                          ),
                          child: Text(
                            buttons[0].text.isNotEmpty ? buttons[0].text.toUpperCase() : 'LATER',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => onButtonTap(buttons[1]),
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: AppColors.white,
                          ),
                          child: Text(
                            buttons[1].text.isNotEmpty ? buttons[1].text.toUpperCase() : 'OK',
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  ...buttons.map((btn) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => onButtonTap(btn),
                            child: Text(btn.text.isNotEmpty ? btn.text.toUpperCase() : 'OK'),
                          ),
                        ),
                      )),
              ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Close X overlapping top right
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: Icon(Icons.close, color: AppColors.gray500, size: 22),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen in-app message (Braze "Full" / "Full Screen" format). Image ~2/3 of screen, content below.
class _InAppMessageFullScreen extends StatelessWidget {
  const _InAppMessageFullScreen({
    required this.message,
    required this.onDismiss,
    required this.onButtonTap,
  });

  final BrazeInAppMessage message;
  final VoidCallback onDismiss;
  final void Function(BrazeButton) onButtonTap;

  /// Image takes ~2/3 of screen to match Braze full-screen design (hero image dominant).
  static const double _imageHeightFraction = 0.62;

  @override
  Widget build(BuildContext context) {
    final buttons = message.buttons;
    final colors = _InAppMessageColors.fromMessage(message);
    final textDark = AppColors.navy;
    final textMuted = AppColors.gray700;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero image: ~2/3 of screen, full-bleed (extends under status bar)
              if (message.imageUrl.isNotEmpty)
                _InAppMessageHeaderImage(
                  url: message.imageUrl,
                  placeholderIconBg: colors.iconBackground,
                  placeholderIconColor: colors.iconColor,
                  height: screenHeight * _imageHeightFraction,
                )
              else
                Container(
                  height: screenHeight * _imageHeightFraction,
                  alignment: Alignment.center,
                  child: _InAppMessageImage(
                    url: message.imageUrl,
                    size: 80,
                    placeholderIconBg: colors.iconBackground,
                    placeholderIconColor: colors.iconColor,
                  ),
                ),
              // Content on white: safe area for bottom (home indicator), scrollable
              Expanded(
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.header.isNotEmpty)
                          Text(
                            message.header,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                        if (message.header.isNotEmpty && message.message.isNotEmpty) const SizedBox(height: 8),
                        if (message.message.isNotEmpty)
                          Text(
                            message.message,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textMuted),
                          ),
                        if (buttons.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          if (buttons.length == 1)
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => onButtonTap(buttons[0]),
                                style: FilledButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: AppColors.white,
                                ),
                                child: Text(buttons[0].text.isNotEmpty ? buttons[0].text.toUpperCase() : 'OK'),
                              ),
                            )
                          else if (buttons.length >= 2)
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => onButtonTap(buttons[0]),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: colors.primary,
                                      side: BorderSide(color: colors.primary),
                                    ),
                                    child: Text(
                                      buttons[0].text.isNotEmpty ? buttons[0].text.toUpperCase() : 'LATER',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () => onButtonTap(buttons[1]),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: colors.primary,
                                      foregroundColor: AppColors.white,
                                    ),
                                    child: Text(
                                      buttons[1].text.isNotEmpty ? buttons[1].text.toUpperCase() : 'OK',
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            ...buttons.map((btn) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                      onPressed: () => onButtonTap(btn),
                                      child: Text(btn.text.isNotEmpty ? btn.text.toUpperCase() : 'OK'),
                                    ),
                                  ),
                                )),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Close: circular dark background so it’s visible on the image (matches design)
          Positioned(
            top: topPadding + 8,
            right: 12,
            child: Material(
              color: AppColors.gray700.withValues(alpha: 0.7),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.white, size: 22),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InAppMessageSlideup extends StatelessWidget {
  const _InAppMessageSlideup({
    required this.message,
    required this.onDismiss,
    required this.onButtonTap,
  });

  final BrazeInAppMessage message;
  final VoidCallback onDismiss;
  final void Function(BrazeButton) onButtonTap;

  @override
  Widget build(BuildContext context) {
    final colors = _InAppMessageColors.fromMessage(message);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (message.imageUrl.isNotEmpty) ...[
              Center(
                child: _InAppMessageImage(
                  url: message.imageUrl,
                  size: 120,
                  placeholderIconBg: colors.iconBackground,
                  placeholderIconColor: colors.iconColor,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (message.header.isNotEmpty)
              Text(
                message.header,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
            if (message.header.isNotEmpty && message.message.isNotEmpty) const SizedBox(height: 4),
            if (message.message.isNotEmpty)
              Text(
                message.message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray700),
              ),
            if (message.buttons.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...message.buttons.map((btn) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FilledButton(
                      onPressed: () => onButtonTap(btn),
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: AppColors.white,
                      ),
                      child: Text(btn.text.isNotEmpty ? btn.text.toUpperCase() : 'OK'),
                    ),
                  )),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: onDismiss,
              style: TextButton.styleFrom(foregroundColor: colors.primary),
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width header image for modal (uploaded photo). Matches Braze modal preview; use only when message has imageUrl.
class _InAppMessageHeaderImage extends StatelessWidget {
  const _InAppMessageHeaderImage({
    required this.url,
    this.placeholderIconBg,
    this.placeholderIconColor,
    this.height,
  });

  static const double _defaultHeight = 180;

  /// When set (e.g. for full-screen), use this height instead of [_defaultHeight].
  final double? height;

  final String url;
  final Color? placeholderIconBg;
  final Color? placeholderIconColor;

  double get _headerHeight => height ?? _defaultHeight;

  @override
  Widget build(BuildContext context) {
    final topRadius = BorderRadius.vertical(top: Radius.circular(16));

    Widget content;
    if (url.isEmpty) {
      content = Container(
        height: _headerHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: placeholderIconBg ?? AppColors.primaryLight.withValues(alpha: 0.25),
        ),
        child: Icon(
          Icons.campaign_outlined,
          size: 48,
          color: placeholderIconColor ?? AppColors.primary,
        ),
      );
    } else {
      final uri = Uri.tryParse(url);
      final isFile = url.startsWith('file://') || (uri != null && uri.isScheme('file')) || (url.startsWith('/') && !url.startsWith('http'));
      content = SizedBox(
        height: _headerHeight,
        width: double.infinity,
        child: isFile
            ? Image.file(
                File(url.startsWith('file://') ? url.substring(7) : url),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                httpHeaders: const {'User-Agent': 'VeryGoodBurgers/1.0'},
                placeholder: (_, __) => _placeholder(),
                errorWidget: (_, __, ___) {
                  if (kDebugMode) debugPrint('Braze in-app message image failed to load: $url');
                  return _placeholder();
                },
              ),
      );
    }
    return ClipRRect(
      borderRadius: topRadius,
      child: content,
    );
  }

  Widget _placeholder() => Container(
        height: _headerHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: placeholderIconBg ?? AppColors.primaryLight.withValues(alpha: 0.25),
        ),
        child: Icon(
          Icons.campaign_outlined,
          size: 48,
          color: placeholderIconColor ?? AppColors.primary,
        ),
      );
}

/// Loads Braze in-app message image from network or file. Uses cache and placeholders so the image area is always visible.
class _InAppMessageImage extends StatelessWidget {
  const _InAppMessageImage({
    required this.url,
    this.size = 80,
    this.placeholderIconBg,
    this.placeholderIconColor,
  });

  final String url;
  final double size;
  final Color? placeholderIconBg;
  final Color? placeholderIconColor;

  Widget _placeholder(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: placeholderIconBg ?? AppColors.primaryLight.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.campaign_outlined,
          size: size * 0.5,
          color: placeholderIconColor ?? AppColors.primary,
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder(context);

    final uri = Uri.tryParse(url);
    final isFile = url.startsWith('file://') || (uri != null && uri.isScheme('file')) || (url.startsWith('/') && !url.startsWith('http'));

    if (isFile) {
      final path = url.startsWith('file://') ? url.substring(7) : url;
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: size,
          height: size,
          child: Image.file(
            File(path),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _placeholder(context),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.contain,
          httpHeaders: const {'User-Agent': 'VeryGoodBurgers/1.0'},
          placeholder: (_, __) => _placeholder(context),
          errorWidget: (_, __, ___) {
            if (kDebugMode) debugPrint('Braze in-app message image failed to load: $url');
            return _placeholder(context);
          },
        ),
      ),
    );
  }
}
